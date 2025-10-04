<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $categories = Category::where('user_id', $request->user()->id)
            ->withCount('links')
            ->orderBy('order_index', 'asc')
            ->get();

        return response()->json([
            'data' => $categories
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $category = Category::create([
            'user_id' => $request->user()->id,
            'name' => $request->name,
            'order_index' => Category::where('user_id', $request->user()->id)->count(),
        ]);

        return response()->json([
            'data' => $category
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $category = Category::where('user_id', $request->user()->id)
            ->withCount('links')
            ->findOrFail($id);

        return response()->json([
            'data' => $category
        ]);
    }

    public function update(Request $request, $id)
    {
        $category = Category::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $category->update($request->only('name'));

        return response()->json([
            'data' => $category
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $category = Category::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $category->delete();

        return response()->json([
            'message' => 'Category deleted successfully'
        ]);
    }
}