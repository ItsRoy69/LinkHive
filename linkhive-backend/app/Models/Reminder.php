<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Reminder extends Model
{
    use HasFactory;

    protected $fillable = [
        'link_id',
        'user_id',
        'reminder_time',
        'sent',
        'note',
    ];

    protected $casts = [
        'reminder_time' => 'datetime',
        'sent' => 'boolean',
    ];

    public function link(): BelongsTo
    {
        return $this->belongsTo(Link::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}