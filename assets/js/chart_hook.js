import Chart from "chart.js/auto";
import "chartjs-adapter-date-fns";

const chartOptions= {
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
    

const MonitorHook = {
  mounted() {
    const chart = new Chart(this.el, {
      type: 'line',
      data: {
        labels: [],
        datasets: [{
          label: "Balance",
          lineTension: 0,
          borderWidth: 2
        }]
      },
      options: chartOptions
    })

    this.handleEvent("update-balance-chart", (data) => {
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


const LogisticsHook = {
  mounted() {
    const chart = new Chart(this.el, {
      type: 'line',
      data: {
        labels: [],
        datasets: [{
          label: "Ready",
          lineTension: 0,
          borderWidth: 2
        },
        {
          label: "Inventory",
          lineTension: 0,
          borderWidth: 2
        }]
      },
      options: chartOptions
    })

    this.handleEvent("update-logistics-chart", (data) => {
      console.log("Logistics data received:", data);
      chart.data.labels.push(new Date(data.time));
      chart.data.datasets[0].data.push(data.ready);
      chart.data.datasets[1].data.push(data.inventory);

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

export {MonitorHook, LogisticsHook};