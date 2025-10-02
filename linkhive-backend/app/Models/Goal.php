<?php
// app/Models/Goal.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Goal extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'goal_type',
        'title',
        'target_count',
        'progress',
        'deadline',
        'is_completed',
    ];

    protected $casts = [
        'deadline' => 'date',
        'is_completed' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}