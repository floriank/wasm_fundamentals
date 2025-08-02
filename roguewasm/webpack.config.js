import path from 'path';
import webpack from 'webpack';
import HtmlWebpackPlugin from 'html-webpack-plugin';
import process from 'process';

export default {
    entry: "./index.js",
    experiments: {
        asyncWebAssembly: true
    },
    output: {
        path: path.resolve(process.cwd(), 'dist'),
        filename: "index.js"
    },
    plugins: [
        new HtmlWebpackPlugin(),
        new webpack.ProvidePlugin({
            TextDecoder: ['text-encoding', 'TextDecoder'],
            TextEncoder: ['text-encoding', 'TextEncoder'],
        })
    ],
    mode: 'development'
}

