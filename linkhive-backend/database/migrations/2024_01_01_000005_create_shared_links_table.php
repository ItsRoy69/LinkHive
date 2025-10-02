<?php
// database/migrations/2024_01_01_000005_create_shared_links_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('shared_links', function (Blueprint $table) {
            $table->id();
            $table->foreignId('link_id')->constrained()->onDelete('cascade');
            $table->foreignId('shared_with_user_id')->nullable()->constrained('users')->onDelete('cascade');
            $table->string('access_token')->unique();
            $table->boolean('is_public')->default(false);
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();
        });
    }
};