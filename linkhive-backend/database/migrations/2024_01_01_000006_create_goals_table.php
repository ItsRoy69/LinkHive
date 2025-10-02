<?php
// database/migrations/2024_01_01_000006_create_goals_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('goals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->enum('goal_type', ['apply_jobs', 'read_articles', 'custom']);
            $table->string('title');
            $table->integer('target_count');
            $table->integer('progress')->default(0);
            $table->date('deadline')->nullable();
            $table->boolean('is_completed')->default(false);
            $table->timestamps();
        });
    }
};