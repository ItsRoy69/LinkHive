<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Link;
use App\Models\Tag;
use Illuminate\Http\Request;

class LinkController extends Controller
{
    public function index(Request $request)
    {
        $query = Link::where('user_id', $request->user()->id)
            ->with(['category', 'tags']);

        // Filter by type
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by category
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        // Filter by pinned
        if ($request->has('pinned')) {
            $query->where('pinned_flag', $request->boolean('pinned'));
        }

        // Search
        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('url', 'like', "%{$search}%");
            });
        }

        // Order by pinned first, then by created_at
        $links = $query->orderBy('pinned_flag', 'desc')
            ->orderBy('order_index', 'asc')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $links
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'url' => 'required|url',
            'title' => 'nullable|string|max:255',
            'type' => 'nullable|in:job,reel,article,video,other',
            'status' => 'nullable|in:applied,not_applied,read,unread,none',
            'category_id' => 'nullable|exists:categories,id',
            'pinned_flag' => 'nullable|boolean',
        ]);

        $link = Link::create([
            'user_id' => $request->user()->id,
            'url' => $request->url,
            'title' => $request->title,
            'type' => $request->type ?? Link::detectLinkType($request->url),
            'status' => $request->status ?? 'none',
            'category_id' => $request->category_id,
            'pinned_flag' => $request->pinned_flag ?? false,
            'metadata' => $request->metadata,
        ]);

        // Handle tags if provided
        if ($request->has('tags')) {
            $tagIds = [];
            foreach ($request->tags as $tagName) {
                $tag = Tag::firstOrCreate(['name' => $tagName]);
                $tagIds[] = $tag->id;
            }
            $link->tags()->sync($tagIds);
        }

        return response()->json([
            'data' => $link->load(['category', 'tags'])
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $link = Link::where('user_id', $request->user()->id)
            ->with(['category', 'tags'])
            ->findOrFail($id);

        return response()->json([
            'data' => $link
        ]);
    }

    public function update(Request $request, $id)
    {
        $link = Link::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $request->validate([
            'url' => 'sometimes|required|url',
            'title' => 'nullable|string|max:255',
            'type' => 'nullable|in:job,reel,article,video,other',
            'status' => 'nullable|in:applied,not_applied,read,unread,none',
            'category_id' => 'nullable|exists:categories,id',
            'pinned_flag' => 'nullable|boolean',
        ]);

        $link->update($request->only([
            'url', 'title', 'type', 'status', 'category_id', 'pinned_flag', 'metadata'
        ]));

        // Handle tags if provided
        if ($request->has('tags')) {
            $tagIds = [];
            foreach ($request->tags as $tagName) {
                $tag = Tag::firstOrCreate(['name' => $tagName]);
                $tagIds[] = $tag->id;
            }
            $link->tags()->sync($tagIds);
        }

        return response()->json([
            'data' => $link->load(['category', 'tags'])
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $link = Link::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $link->delete();

        return response()->json([
            'message' => 'Link deleted successfully'
        ]);
    }

    public function togglePin(Request $request, $id)
    {
        $link = Link::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $link->update([
            'pinned_flag' => !$link->pinned_flag
        ]);

        return response()->json([
            'data' => $link
        ]);
    }

    public function reorder(Request $request)
    {
        $request->validate([
            'order' => 'required|array',
            'order.*.id' => 'required|exists:links,id',
            'order.*.order_index' => 'required|integer',
        ]);

        foreach ($request->order as $item) {
            Link::where('user_id', $request->user()->id)
                ->where('id', $item['id'])
                ->update(['order_index' => $item['order_index']]);
        }

        return response()->json([
            'message' => 'Links reordered successfully'
        ]);
    }
}