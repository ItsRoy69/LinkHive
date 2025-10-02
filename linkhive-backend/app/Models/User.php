<?php
// app/Models/User.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'settings',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'settings' => 'array',
    ];

    public function links()
    {
        return $this->hasMany(Link::class);
    }

    public function categories()
    {
        return $this->hasMany(Category::class);
    }

    public function goals()
    {
        return $this->hasMany(Goal::class);
    }

    public function reminders()
    {
        return $this->hasMany(Reminder::class);
    }
}