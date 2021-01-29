import Chart from "chart.js";
import * as common from "./common.js";

let chart = undefined;

export function draw_chart(ctx, scores)
{
	if (!ctx) {
		return;
	}

	let { labels, datasets } = common.calculate(scores, (item) => { return item.set_pop });
	chart = common.draw_chart(ctx.getContext('2d'), chart, labels, datasets);
}

export function destroy()
{
	if (chart) {
		chart.destroy();
		chart = undefined;
	}
}
