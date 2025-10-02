<?php
// app/Http/Controllers/Api/GoalController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Goal;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    public function index(Request $request)
    {
        $goals = $request->user()->goals()
            ->orderBy('is_completed')
            ->orderBy('deadline')
            ->get();

        return response()->json($goals);
    }

    public function store(Request $request)
    {
        $request->validate([
            'goal_type' => 'required|in:apply_jobs,read_articles,custom',
            'title' => 'required|string|max:255',
            'target_count' => 'required|integer|min:1',
            'deadline' => 'nullable|date|after:today',
        ]);

        $goal = $request->user()->goals()->create($request->only([
            'goal_type',
            'title',
            'target_count',
            'deadline',
        ]));

        return response()->json($goal, 201);
    }

    public function show(Request $request, Goal $goal)
    {
        if ($goal->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json($goal);
    }

    public function update(Request $request, Goal $goal)
    {
        if ($goal->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'title' => 'string|max:255',
            'target_count' => 'integer|min:1',
            'progress' => 'integer|min:0',
            'deadline' => 'nullable|date',
            'is_completed' => 'boolean',
        ]);

        $goal->update($request->only([
            'title',
            'target_count',
            'progress',
            'deadline',
            'is_completed',
        ]));

        return response()->json($goal);
    }

    public function destroy(Request $request, Goal $goal)
    {
        if ($goal->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $goal->delete();
        return response()->json(['message' => 'Goal deleted successfully']);
    }
}