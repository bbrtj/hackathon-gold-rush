<template>
	<div class="ml-20 mr-20">
		<h1 class="text-5xl text-center p-4 text-gray-500">Current leader: {{ leader }}</h1>
		<div v-if="error">
			<h2 class="text-red-500 text-center font-semibold text-lg">Error: {{ error }}</h2>
		</div>
		Show: <select class="w-40" v-model="selected_chart" v-on:change="draw_charts">
			<option value="gold" selected>Gold</option>
			<option value="settlements">Settlements</option>
			<option value="mines">Mines</option>
			<option value="population">Population</option>
			<option value="workers">Workers</option>
		</select>
		<div v-if="selected_chart == 'gold'">
			<canvas class="chart mt-2 mb-2" ref="gold_chart" width="400" height="170"></canvas>
		</div>
		<div v-if="selected_chart == 'settlements'">
			<canvas class="chart mt-2 mb-2" ref="settlements_chart" width="400" height="170"></canvas>
		</div>
		<div v-if="selected_chart == 'mines'">
			<canvas class="chart mt-2 mb-2" ref="mines_chart" width="400" height="170"></canvas>
		</div>
		<div v-if="selected_chart == 'population'">
			<canvas class="chart mt-2 mb-2" ref="population_chart" width="400" height="170"></canvas>
		</div>
		<div v-if="selected_chart == 'workers'">
			<canvas class="chart mt-2 mb-2" ref="workers_chart" width="400" height="170"></canvas>
		</div>
	</div>
</template>

<script>
import axios from "axios";
import * as gold_chart from "../chart/GoldChart";
import * as population_chart from "../chart/PopulationChart";
import * as settlements_chart from "../chart/SettlementsChart";
import * as mines_chart from "../chart/MinesChart";
import * as workers_chart from "../chart/WorkersChart";

export default {
	data() {
		return {
			scores: {},
			leader: "(Game hasn't started yet)",
			error: undefined,
			selected_chart: 'gold',
		}
	},
	methods: {
		redraw() {
			this.error = undefined;
			let max_score = 0;
			for (let player in this.scores) {
				let last_turn = this.scores[player].slice(-1)[0];
				if (last_turn.gold > max_score) {
					this.leader = player;
					max_score = last_turn.gold;
				}
			}
			this.update_charts();
		},
		fetch() {
			axios.get("/api/scores")
				.then(res => {
					this.scores = res.data;
					this.redraw();
				})
				.catch(err => {
					this.error = "Couldn't connect to the server";
					console.error(err);
				});
		},
		draw_charts() {
			gold_chart.destroy();
			settlements_chart.destroy();
			mines_chart.destroy();
			population_chart.destroy();
			workers_chart.destroy();

			this.$nextTick(() => {
				this.update_charts();
			});
		},
		update_charts() {
			gold_chart.draw_chart(this.$refs.gold_chart, this.scores);
			settlements_chart.draw_chart(this.$refs.settlements_chart, this.scores);
			mines_chart.draw_chart(this.$refs.mines_chart, this.scores);
			population_chart.draw_chart(this.$refs.population_chart, this.scores);
			workers_chart.draw_chart(this.$refs.workers_chart, this.scores);
		},
	},
	mounted() {
		setInterval(this.fetch, 15 * 1000);
		this.$nextTick(function() {
			this.fetch();
		});
	},
}
</script>

<style scoped>
</style>
