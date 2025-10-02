<?php
// app/Http/Controllers/Api/ReminderController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Reminder;
use Illuminate\Http\Request;

class ReminderController extends Controller
{
    public function index(Request $request)
    {
        $reminders = $request->user()->reminders()
            ->with('link')
            ->orderBy('reminder_time')
            ->get();

        return response()->json($reminders);
    }

    public function store(Request $request)
    {
        $request->validate([
            'link_id' => 'required|exists:links,id',
            'reminder_time' => 'required|date|after:now',
            'message' => 'nullable|string|max:255',
        ]);

        // Verify the link belongs to the user
        $link = $request->user()->links()->findOrFail($request->link_id);

        $reminder = $request->user()->reminders()->create([
            'link_id' => $request->link_id,
            'reminder_time' => $request->reminder_time,
            'message' => $request->message,
        ]);

        return response()->json($reminder->load('link'), 201);
    }

    public function show(Request $request, Reminder $reminder)
    {
        if ($reminder->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json($reminder->load('link'));
    }

    public function update(Request $request, Reminder $reminder)
    {
        if ($reminder->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'reminder_time' => 'date|after:now',
            'message' => 'nullable|string|max:255',
            'is_sent' => 'boolean',
        ]);

        $reminder->update($request->only(['reminder_time', 'message', 'is_sent']));

        return response()->json($reminder->load('link'));
    }

    public function destroy(Request $request, Reminder $reminder)
    {
        if ($reminder->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $reminder->delete();
        return response()->json(['message' => 'Reminder deleted successfully']);
    }
}