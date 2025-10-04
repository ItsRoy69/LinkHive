<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reminders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('link_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->timestamp('reminder_time');
            $table->boolean('sent')->default(false);
            $table->text('note')->nullable();
            $table->timestamps();
            
            $table->index(['reminder_time', 'sent']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reminders');
    }
};