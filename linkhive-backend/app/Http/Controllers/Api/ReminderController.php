<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Reminder;
use Illuminate\Http\Request;

class ReminderController extends Controller
{
    public function index(Request $request)
    {
        $reminders = Reminder::where('user_id', $request->user()->id)
            ->with('link')
            ->orderBy('reminder_time', 'asc')
            ->get();

        return response()->json([
            'data' => $reminders
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'link_id' => 'required|exists:links,id',
            'reminder_time' => 'required|date|after:now',
            'note' => 'nullable|string',
        ]);

        $reminder = Reminder::create([
            'user_id' => $request->user()->id,
            'link_id' => $request->link_id,
            'reminder_time' => $request->reminder_time,
            'note' => $request->note,
        ]);

        return response()->json([
            'data' => $reminder->load('link')
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $reminder = Reminder::where('user_id', $request->user()->id)
            ->with('link')
            ->findOrFail($id);

        return response()->json([
            'data' => $reminder
        ]);
    }

    public function update(Request $request, $id)
    {
        $reminder = Reminder::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $request->validate([
            'reminder_time' => 'sometimes|required|date',
            'note' => 'nullable|string',
            'sent' => 'sometimes|boolean',
        ]);

        $reminder->update($request->all());

        return response()->json([
            'data' => $reminder->load('link')
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $reminder = Reminder::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $reminder->delete();

        return response()->json([
            'message' => 'Reminder deleted successfully'
        ]);
    }
}