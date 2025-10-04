<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Get all links for the user.
     */
    public function links(): HasMany
    {
        return $this->hasMany(Link::class);
    }

    /**
     * Get all categories for the user.
     */
    public function categories(): HasMany
    {
        return $this->hasMany(Category::class);
    }

    /**
     * Get all goals for the user.
     */
    public function goals(): HasMany
    {
        return $this->hasMany(Goal::class);
    }

    /**
     * Get all reminders for the user.
     */
    public function reminders(): HasMany
    {
        return $this->hasMany(Reminder::class);
    }

    /**
     * Get pinned links for the user.
     */
    public function pinnedLinks(): HasMany
    {
        return $this->hasMany(Link::class)->where('pinned_flag', true)->orderBy('order_index');
    }

    /**
     * Get active goals for the user.
     */
    public function activeGoals(): HasMany
    {
        return $this->hasMany(Goal::class)
            ->where('completed', false)
            ->where('end_date', '>=', now());
    }

    /**
     * Get upcoming reminders for the user.
     */
    public function upcomingReminders(): HasMany
    {
        return $this->hasMany(Reminder::class)
            ->where('sent', false)
            ->where('reminder_time', '>=', now())
            ->orderBy('reminder_time');
    }
}