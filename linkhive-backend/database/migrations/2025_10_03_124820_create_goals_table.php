<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('goals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('goal_type'); // e.g., 'apply_jobs', 'read_articles'
            $table->string('description');
            $table->integer('target_count');
            $table->integer('progress')->default(0);
            $table->date('start_date');
            $table->date('end_date');
            $table->boolean('completed')->default(false);
            $table->timestamps();
            
            $table->index(['user_id', 'completed']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('goals');
    }
};