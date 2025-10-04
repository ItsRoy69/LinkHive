<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

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

    protected static function boot()
    {
        parent::boot();
        
        static::creating(function ($model) {
            if (!$model->access_token) {
                $model->access_token = Str::random(32);
            }
        });
    }

    public function link(): BelongsTo
    {
        return $this->belongsTo(Link::class);
    }

    public function sharedWithUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'shared_with_user_id');
    }
}