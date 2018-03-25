App.comments = App.cable.subscriptions.create("ProductsChannel", {
    connected: function() {},
    disconnected: function() {},
    received: function(data) {
        var period = $("#chart-container").data("period");
        var date = new Date();
        date.setDate(date.getDate() - period);
        var max_price = [];
        var min_price = [];
        if(window.location.pathname.split('/')[2] == data.id){
            for(var i = 0; i < data.max_price.length; i++) {
                var rubyDate = new Date(data.max_price[i][0]);
                console.log(rubyDate);
                console.log(date);
                if(rubyDate > date){
                    max_price.push(data.max_price[i]);
                    min_price.push(data.min_price[i]);
                }
            }
            var min = this.getMin(min_price);
            var chart = new Chartkick.AreaChart("chart-container",
                [{name: 'min', data: min_price}, {name: 'max', data: max_price}],
                {min: min});
        }
    },
    getMin: function(min_price) {
        var min = parseInt(min_price[0][1]) - parseInt(min_price[0][1], 10) * 0.03;
        for(var i = 0; i < min_price.length; i++) {
            if(min > parseInt(min_price[i][1]) - parseInt(min_price[i][1], 10) * 0.03){
                min = parseInt(min_price[i][1]) - parseInt(min_price[i][1], 10) * 0.03;
            }
        }
        return min;
    }
});