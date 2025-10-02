<?php
// app/Models/Link.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Link extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'category_id',
        'url',
        'title',
        'type',
        'status',
        'metadata',
        'shared_flag',
        'pinned_flag',
        'order_index',
        'is_dead',
    ];

    protected $casts = [
        'metadata' => 'array',
        'shared_flag' => 'boolean',
        'pinned_flag' => 'boolean',
        'is_dead' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function tags()
    {
        return $this->hasMany(Tag::class);
    }

    public function sharedLinks()
    {
        return $this->hasMany(SharedLink::class);
    }

    public function reminders()
    {
        return $this->hasMany(Reminder::class);
    }
}