<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\LinkController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\GoalController;
use App\Http\Controllers\Api\ReminderController;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    
    // Links
    Route::apiResource('links', LinkController::class);
    Route::post('/links/{id}/toggle-pin', [LinkController::class, 'togglePin']);
    Route::post('/links/reorder', [LinkController::class, 'reorder']);
    
    // Categories
    Route::apiResource('categories', CategoryController::class);
    
    // Goals
    Route::apiResource('goals', GoalController::class);
    
    // Reminders
    Route::apiResource('reminders', ReminderController::class);
});