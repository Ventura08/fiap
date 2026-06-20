package com.fiap.vinheriaestoque.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(
    entities = [Produto::class],
    version = 1,
    exportSchema = false,
)
abstract class AgnelloDatabase : RoomDatabase() {
    abstract fun produtoDao(): ProdutoDao

    companion object {
        @Volatile
        private var instance: AgnelloDatabase? = null

        fun getInstance(context: Context): AgnelloDatabase =
            instance ?: synchronized(this) {
                instance ?: Room.databaseBuilder(
                    context.applicationContext,
                    AgnelloDatabase::class.java,
                    "agnello_estoque.db",
                ).build().also { instance = it }
            }
    }
}
