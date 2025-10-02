<?php
// routes/api.php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\LinkController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\GoalController;
use App\Http\Controllers\Api\ReminderController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('shared/{token}', [LinkController::class, 'getShared']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Links
    Route::apiResource('links', LinkController::class);
    Route::post('links/{link}/toggle-pin', [LinkController::class, 'togglePin']);
    Route::post('links/reorder', [LinkController::class, 'reorder']);
    Route::post('links/{link}/share', [LinkController::class, 'share']);
    
    // Categories
    Route::apiResource('categories', CategoryController::class);
    
    // Goals
    Route::apiResource('goals', GoalController::class);
    
    // Reminders
    Route::apiResource('reminders', ReminderController::class);
});