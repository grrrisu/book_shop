import Chart from "chart.js/auto";
import "chartjs-adapter-date-fns";

const MonitorHook = {
  mounted() {
    const chart = new Chart(this.el, {
      type: 'line',
      data: {
        labels: [],
        datasets: [{
          label: "Balance",
          borderColor: "rgb(6, 182, 212, 0.8)",
          backgroundColor: "rgb(14, 116, 144, 0.8)",
          lineTension: 0,
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        scales: {
          x: {
            display: true,
            type: 'time',
            time: {
              displayFormats: {
                second: 'mm:ss',
                minute: 'mm',
                hour: 'HH:mm',
                day: 'MMM dd'
              }
            },
            ticks: {
              color: "rgb(14, 165, 233, 0.8)",
            },
            
          },
          y: {
            display: true,
            beginAtZero: false,
            ticks: {
              color: "rgb(14, 165, 233, 0.8)",
            },
          }
        }
      }
    })

    this.handleEvent("update-balance-chart", (data) => {
      console.log("Received data:", data);
      console.log("time:", new Date(data.time));
      chart.data.labels.push(new Date(data.time));
      chart.data.datasets[0].data.push(data.balance);

      // Limit the number of data points to prevent memory issues
      const maxDataPoints = 50;
      if (chart.data.labels.length > maxDataPoints) {
        chart.data.labels.shift();
        chart.data.datasets[0].data.shift();
      }
      chart.update();
    });
  }
}

export default MonitorHook;