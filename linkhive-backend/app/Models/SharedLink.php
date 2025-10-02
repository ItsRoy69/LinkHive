<?php
// app/Models/SharedLink.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SharedLink extends Model
{
    use HasFactory;

    protected $fillable = [
        'link_id',
        'shared_with_user_id',
        'access_token',
        'is_public',
        'expires_at',
    ];

    protected $casts = [
        'is_public' => 'boolean',
        'expires_at' => 'datetime',
    ];

    public function link()
    {
        return $this->belongsTo(Link::class);
    }

    public function sharedWithUser()
    {
        return $this->belongsTo(User::class, 'shared_with_user_id');
    }
}