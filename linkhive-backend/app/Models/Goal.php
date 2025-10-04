<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Goal extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'goal_type',
        'description',
        'target_count',
        'progress',
        'start_date',
        'end_date',
        'completed',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'completed' => 'boolean',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function updateProgress(): void
    {
        // Logic to calculate progress based on link statuses
        $this->progress = min($this->target_count, $this->progress + 1);
        $this->completed = $this->progress >= $this->target_count;
        $this->save();
    }
}