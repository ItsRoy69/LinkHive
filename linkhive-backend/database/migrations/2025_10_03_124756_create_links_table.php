<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('links', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('category_id')->nullable()->constrained()->onDelete('set null');
            $table->text('url');
            $table->string('title')->nullable();
            $table->enum('type', ['job', 'reel', 'article', 'video', 'other'])->default('other');
            $table->enum('status', ['applied', 'not_applied', 'read', 'unread', 'none'])->default('none');
            $table->json('metadata')->nullable();
            $table->boolean('shared_flag')->default(false);
            $table->boolean('pinned_flag')->default(false);
            $table->integer('order_index')->default(0);
            $table->boolean('is_dead')->default(false);
            $table->timestamps();
            
            $table->index(['user_id', 'type']);
            $table->index(['user_id', 'pinned_flag']);
            $table->index(['user_id', 'category_id']);
            $table->fullText(['title', 'url']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('links');
    }
};