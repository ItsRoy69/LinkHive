<?php
// database/migrations/2024_01_01_000007_create_reminders_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('reminders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('link_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->timestamp('reminder_time');
            $table->string('message')->nullable();
            $table->boolean('is_sent')->default(false);
            $table->timestamps();
            
            $table->index(['reminder_time', 'is_sent']);
        });
    }
};