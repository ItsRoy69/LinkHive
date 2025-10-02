<?php
// app/Models/Reminder.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Reminder extends Model
{
    use HasFactory;

    protected $fillable = [
        'link_id',
        'user_id',
        'reminder_time',
        'message',
        'is_sent',
    ];

    protected $casts = [
        'reminder_time' => 'datetime',
        'is_sent' => 'boolean',
    ];

    public function link()
    {
        return $this->belongsTo(Link::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}