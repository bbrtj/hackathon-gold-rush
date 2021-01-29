import Vue from "vue";
import Scores from "./component/Scores.vue";
import css from './scores.css';

let instance = new Vue({
	render: (h) => h(Scores)
}).$mount("#scores");
