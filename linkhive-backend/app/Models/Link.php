<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

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

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class, 'link_tag');
    }

    public function reminders(): HasMany
    {
        return $this->hasMany(Reminder::class);
    }

    public function sharedLinks(): HasMany
    {
        return $this->hasMany(SharedLink::class);
    }

    // Auto-detect link type based on URL
    public static function detectLinkType(string $url): string
    {
        $url = strtolower($url);
        
        if (str_contains($url, 'linkedin.com/jobs') || 
            str_contains($url, 'indeed.com') || 
            str_contains($url, 'naukri.com')) {
            return 'job';
        }
        
        if (str_contains($url, 'instagram.com/reel') || 
            str_contains($url, 'tiktok.com')) {
            return 'reel';
        }
        
        if (str_contains($url, 'youtube.com') || 
            str_contains($url, 'youtu.be') ||
            str_contains($url, 'vimeo.com')) {
            return 'video';
        }
        
        if (str_contains($url, 'medium.com') || 
            str_contains($url, 'dev.to') ||
            str_contains($url, '/article') ||
            str_contains($url, '/blog')) {
            return 'article';
        }
        
        return 'other';
    }
}