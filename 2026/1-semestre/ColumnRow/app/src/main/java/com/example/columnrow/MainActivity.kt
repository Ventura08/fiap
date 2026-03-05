package com.example.columnrow

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.columnrow.ui.theme.ColumnRowTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            ColumnRowTheme {
                Surface(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(200.dp),
                    color = MaterialTheme.colorScheme.background
                ) {
                    ColumnRowScreen()
                    Box()
                }
            }
        }
    }
}

@Composable
fun ColumnRowScreen() {
    Column(
        modifier = Modifier
            .background(Color.Cyan)
    ) {
        Column(
            modifier = Modifier
                .background(Color.Magenta)
                .fillMaxWidth()
                .height(150.dp)
        ) {
        }
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(150.dp)
                .background(Color.Green)
        ) {
        }
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(150.dp)
                .background(Color.Yellow)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(100.dp)
                    .padding(8.dp)
                    .background(Color.Red)
                    .weight(0.3f)
            ) {
            }
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(100.dp)
                    .padding(8.dp)
                    .background(Color.Blue)
                    .weight(0.7f)
            ) {
            }
        }
    }
}