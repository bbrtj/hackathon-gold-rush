import Chart from "chart.js";

export function calculate(scores, score_func)
{
	let labels = [];
	let datasets = [];

	let players = Object.keys(scores);
	players.sort((a, b) => {
		return scores[b].slice(-1)[0].gold
		- scores[a].slice(-1)[0].gold;
	});

	let colors = ['gold', 'blue', 'green'];

	for (let player of players) {
		if (labels.length === 0) {
			labels = scores[player].map((item) => {
				return "Turn " + item.turn
			});
		}

		let color = colors.shift() || 'gray';
		datasets.push({
			label: player,
			data: scores[player].map(score_func),
			fill: false,
			backgroundColor: color,
			borderColor: color,
		});
	}

	return {
		labels: labels,
		datasets: datasets,
	};
}

export function draw_chart(ctx, chart, labels, datasets)
{
	if (!chart) {
		chart = new Chart(ctx, {
			type: 'line',
			data: {
				labels: labels,
				datasets: datasets,
			},
			options: {
				scales: {
					xAxes:[{
						display: false,
					}],
					yAxes: [{
						display: true,
						ticks: {
							beginAtZero: true
						}
					}]
				}
			}
		});
	}
	else {
		chart.data.labels = labels;
		chart.data.datasets = datasets;
		chart.update({duration: 0});
	}

	return chart;
}
