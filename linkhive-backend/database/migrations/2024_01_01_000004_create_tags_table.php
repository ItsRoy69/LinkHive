<?php
// database/migrations/2024_01_01_000004_create_tags_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('tags', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->foreignId('link_id')->constrained()->onDelete('cascade');
            $table->timestamps();
            
            $table->index(['name', 'link_id']);
        });
    }
};