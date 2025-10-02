<?php
// app/Http/Controllers/Api/LinkController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Link;
use App\Models\SharedLink;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class LinkController extends Controller
{
    public function index(Request $request)
    {
        $query = $request->user()->links()->with(['category', 'tags']);

        // Filters
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->has('pinned')) {
            $query->where('pinned_flag', $request->boolean('pinned'));
        }

        if ($request->has('search')) {
            $query->where(function($q) use ($request) {
                $q->where('title', 'LIKE', '%' . $request->search . '%')
                  ->orWhere('url', 'LIKE', '%' . $request->search . '%');
            });
        }

        // Sorting
        $query->orderBy('pinned_flag', 'desc')
              ->orderBy('order_index')
              ->orderBy('created_at', 'desc');

        $links = $query->paginate(20);

        return response()->json($links);
    }

    public function store(Request $request)
    {
        $request->validate([
            'url' => 'required|url',
            'title' => 'nullable|string|max:255',
            'type' => 'nullable|in:job,reel,article,video,other',
            'category_id' => 'nullable|exists:categories,id',
            'status' => 'nullable|in:applied,not_applied,read,unread',
            'tags' => 'nullable|array',
            'tags.*' => 'string|max:50',
        ]);

        $link = $request->user()->links()->create([
            'url' => $request->url,
            'title' => $request->title ?? $this->extractTitle($request->url),
            'type' => $request->type ?? $this->detectLinkType($request->url),
            'category_id' => $request->category_id,
            'status' => $request->status ?? 'unread',
            'metadata' => $this->extractMetadata($request->url),
        ]);

        // Add tags
        if ($request->has('tags')) {
            foreach ($request->tags as $tagName) {
                $link->tags()->create(['name' => $tagName]);
            }
        }

        return response()->json($link->load(['category', 'tags']), 201);
    }

    public function show(Request $request, Link $link)
    {
        // Check if the link belongs to the authenticated user
        if ($link->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        
        return response()->json($link->load(['category', 'tags', 'reminders']));
    }

    public function update(Request $request, Link $link)
    {
        // Check if the link belongs to the authenticated user
        if ($link->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'title' => 'nullable|string|max:255',
            'type' => 'nullable|in:job,reel,article,video,other',
            'category_id' => 'nullable|exists:categories,id',
            'status' => 'nullable|in:applied,not_applied,read,unread',
            'pinned_flag' => 'boolean',
        ]);

        $link->update($request->only(['title', 'type', 'category_id', 'status', 'pinned_flag']));

        return response()->json($link->load(['category', 'tags']));
    }

    public function destroy(Request $request, Link $link)
    {
        // Check if the link belongs to the authenticated user
        if ($link->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        
        $link->delete();
        return response()->json(['message' => 'Link deleted successfully']);
    }

    public function togglePin(Request $request, Link $link)
    {
        if ($link->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $link->update(['pinned_flag' => !$link->pinned_flag]);

        return response()->json($link);
    }

    public function reorder(Request $request)
    {
        $request->validate([
            'links' => 'required|array',
            'links.*.id' => 'required|exists:links,id',
            'links.*.order_index' => 'required|integer|min:0',
        ]);

        foreach ($request->links as $linkData) {
            $link = Link::find($linkData['id']);
            if ($link && $link->user_id === $request->user()->id) {
                $link->update(['order_index' => $linkData['order_index']]);
            }
        }

        return response()->json(['message' => 'Links reordered successfully']);
    }

    public function share(Request $request, Link $link)
    {
        if ($link->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'is_public' => 'boolean',
            'shared_with_user_id' => 'nullable|exists:users,id',
            'expires_at' => 'nullable|date|after:now',
        ]);

        $sharedLink = $link->sharedLinks()->create([
            'shared_with_user_id' => $request->shared_with_user_id,
            'access_token' => Str::random(32),
            'is_public' => $request->boolean('is_public'),
            'expires_at' => $request->expires_at,
        ]);

        return response()->json($sharedLink, 201);
    }

    public function getShared(Request $request, $token)
    {
        $sharedLink = SharedLink::where('access_token', $token)
            ->where(function($query) {
                $query->whereNull('expires_at')
                      ->orWhere('expires_at', '>', now());
            })
            ->firstOrFail();

        // Check if user has access (only if user is authenticated)
        $user = $request->user();
        if (!$sharedLink->is_public && (!$user || $sharedLink->shared_with_user_id !== $user->id)) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json($sharedLink->link->load(['category', 'tags']));
    }

    private function detectLinkType($url)
    {
        // Simple link type detection logic
        if (strpos($url, 'linkedin.com/jobs') !== false || strpos($url, 'indeed.com') !== false) {
            return 'job';
        }
        if (strpos($url, 'instagram.com/reel') !== false || strpos($url, 'tiktok.com') !== false) {
            return 'reel';
        }
        if (strpos($url, 'youtube.com') !== false || strpos($url, 'youtu.be') !== false) {
            return 'video';
        }
        return 'article';
    }

    private function extractTitle($url)
    {
        // Simple title extraction - in production, use a proper URL parser
        return parse_url($url, PHP_URL_HOST);
    }

    private function extractMetadata($url)
    {
        return ['original_url' => $url, 'extracted_at' => now()];
    }
}