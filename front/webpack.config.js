const path = require('path');
const VueLoaderPlugin = require('vue-loader/lib/plugin')

module.exports = {
	entry: {
		scores: './src/scores.js',
	},
	output: {
		path: path.resolve(__dirname, '../public'),
		filename: '[name].js',
	},
	module: {
		rules: [
			{
				test: /\.vue$/,
				loader: 'vue-loader'
			},
			{
				test: /\.css$/,
				use: [
					'vue-style-loader',
					'style-loader',
					'css-loader',
					'postcss-loader'
				]
			}
		]
	},
	plugins: [
		new VueLoaderPlugin()
	]
};
