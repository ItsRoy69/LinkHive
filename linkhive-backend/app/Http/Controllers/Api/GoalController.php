<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Goal;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    public function index(Request $request)
    {
        $goals = Goal::where('user_id', $request->user()->id)
            ->orderBy('end_date', 'asc')
            ->get();

        return response()->json([
            'data' => $goals
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'goal_type' => 'required|string',
            'description' => 'required|string',
            'target_count' => 'required|integer|min:1',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        $goal = Goal::create([
            'user_id' => $request->user()->id,
            'goal_type' => $request->goal_type,
            'description' => $request->description,
            'target_count' => $request->target_count,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
        ]);

        return response()->json([
            'data' => $goal
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $goal = Goal::where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'data' => $goal
        ]);
    }

    public function update(Request $request, $id)
    {
        $goal = Goal::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $request->validate([
            'goal_type' => 'sometimes|required|string',
            'description' => 'sometimes|required|string',
            'target_count' => 'sometimes|required|integer|min:1',
            'progress' => 'sometimes|required|integer|min:0',
            'start_date' => 'sometimes|required|date',
            'end_date' => 'sometimes|required|date|after_or_equal:start_date',
        ]);

        $goal->update($request->all());

        return response()->json([
            'data' => $goal
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $goal = Goal::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $goal->delete();

        return response()->json([
            'message' => 'Goal deleted successfully'
        ]);
    }
}