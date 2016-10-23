var allTimeSeries = {};
var allValueLabels = {};
var descriptions = {
    'Optimizer 1: Memory': {
        'swpd_dec': 'Amount of virtual memory used',
        //'free_dec': 'Amount of idle memory',
        'buff_dec': 'Amount of memory used as buffers',
        'cache_dec': 'Amount of memory used as cache'
    },
    'Optimizer 2: Memory': {
        'swpd_com': 'Amount of virtual memory used',
        //'free_com': 'Amount of idle memory',
        'buff_com': 'Amount of memory used as buffers',
        'cache_com': 'Amount of memory used as cache'
    },
    'Optimizer 1: CPU': {
        'us_dec': 'Time spent running non-kernel code (user time, including nice time)',
        'sy_dec': 'Time spent running kernel code (system time)',
        //'id_dec': 'Time spent idle',
        'wa_dec': 'Time spent waiting for IO'
    },
    'Optimizer 2: CPU': {
        'us_com': 'Time spent running non-kernel code (user time, including nice time)',
        'sy_com': 'Time spent running kernel code (system time)',
        //'id_com': 'Time spent idle',
        'wa_com': 'Time spent waiting for IO'
    }
}

function streamStats() {

    console.log(dominio);
    var ws = new ReconnectingWebSocket(dominio);

    var lineCount;
    var colHeadings;

    ws.onopen = function() {
        console.log('connect');
        lineCount = 0;
    };

    ws.onclose = function() {
        console.log('disconnect');
    };

    ws.onmessage = function(e) {
        switch (lineCount++) {
            case 0: // ignore first line
                break;

            case 1: // column headings
                colHeadings = e.data.trim().split(/ +/);
                break;

            default: // subsequent lines
                var colValues = e.data.trim().split(/ +/);
                var stats = {};
                for (var i = 0; i < colHeadings.length; i++) {
                    stats[colHeadings[i]] = parseInt(colValues[i]);
                }
                receiveStats(stats);
        }
    };
}
function streamStats2() {

    console.log(dominio2);
    var ws2 = new ReconnectingWebSocket(dominio2);

    var lineCount2;
    var colHeadings2;

    ws2.onopen = function() {
        console.log('connect');
        lineCount2 = 0;
    };

    ws2.onclose = function() {
        console.log('disconnect');
    };

    ws2.onmessage = function(e) {
        switch (lineCount2++) {
            case 0: // ignore first line
                break;

            case 1: // column headings
                colHeadings2 = e.data.trim().split(/ +/);
                break;

            default: // subsequent lines
                var colValues2 = e.data.trim().split(/ +/);
                var stats2 = {};
                for (var i = 0; i < colHeadings2.length; i++) {
                    stats2[colHeadings2[i]] = parseInt(colValues2[i]);
                }
                receiveStats(stats2);
        }
    };
}

function streamStats3() {

    console.log(dominio3);
    var ws3 = new ReconnectingWebSocket(dominio3);

    var lineCount3;
    var colHeadings3;

    ws3.onopen = function() {
        console.log('connect');
        lineCount3 = 0;
    };

    ws3.onclose = function() {
        console.log('disconnect');
    };

    ws3.onmessage = function(e) {
        switch (lineCount3++) {
            case 0: // ignore first line
                break;

            case 1: // column headings
                colHeadings3 = e.data.trim().split(/ +/);
                break;

            default: // subsequent lines
                var colValues3 = e.data.trim().split(/ +/);
                var stats3 = {};
                for (var i = 0; i < colHeadings3.length; i++) {
                    stats3[colHeadings3[i]] = parseInt(colValues3[i]);
                }
                receiveStats(stats3);
        }
    };
}

function streamStats4() {

    console.log(dominio4);
    var ws4 = new ReconnectingWebSocket(dominio4);

    var lineCount4;
    var colHeadings4;

    ws4.onopen = function() {
        console.log('connect');
        lineCount4 = 0;
    };

    ws4.onclose = function() {
        console.log('disconnect');
    };

    ws4.onmessage = function(e) {
        switch (lineCount4++) {
            case 0: // ignore first line
                break;

            case 1: // column headings
                colHeadings4 = e.data.trim().split(/ +/);
                break;

            default: // subsequent lines
                var colValues4 = e.data.trim().split(/ +/);
                var stats4 = {};
                for (var i = 0; i < colHeadings4.length; i++) {
                    stats4[colHeadings4[i]] = parseInt(colValues4[i]);
                }
                receiveStats(stats4);
        }
    };
}

function initCharts() {
    Object.each(descriptions, function(sectionName, values) {
        var section = $('.chart.template').clone().removeClass('template').appendTo('#charts');

        section.find('.title').text(sectionName);

        var smoothie = new SmoothieChart({
            millisPerPixel: 500,
            grid: {
                fillStyle: '#ffffff',
                sharpLines: true,
                verticalSections: 5,
                strokeStyle: 'rgba(243,191,191,0.45)',
                millisPerLine: 5000
            },
            minValue: 0,
            labels: {
                disabled: true
            }
        });
        smoothie.streamTo(section.find('canvas').get(0), 1000);

        //var colors = chroma.brewer['Dark2'];   
        var colors = ['#00cc00', '#ff8000', '#7570b3', '#e7298a', '#66a61e', '#e6ab02', '#a6761d', '#666666'];   
        var index = 0;
        Object.each(values, function(name, valueDescription) {
            var color = colors[index++];

            var timeSeries = new TimeSeries();
            smoothie.addTimeSeries(timeSeries, {
                strokeStyle: color,
                fillStyle: chroma(color).darken().alpha(0.5).css(),
                lineWidth: 3
            });
            allTimeSeries[name] = timeSeries;

            var statLine = section.find('.stat.template').clone().removeClass('template').appendTo(section.find('.stats'));
            statLine.attr('title', valueDescription).css('color', color);
            statLine.find('.stat-name').text(name);
            allValueLabels[name] = statLine.find('.stat-value');
        });
    });
}

function receiveStats(stats) {
    Object.each(stats, function(name, value) {
        var timeSeries = allTimeSeries[name];
        if (timeSeries) {
            timeSeries.append(Date.now(), value);
            allValueLabels[name].text(value);
        }
    });
}

function respondCanvas(){
            
        //Get the canvas & context
  	var c = $('.respondCanvas');
  	var ct = c.get(0).getContext('2d');
  	var container = $(c).parent();
  		
  	//Run function when browser  resize
	$.each(c, function(key, value){
  		$(value).attr('width', $(value).parent().width() ); //max width   
        })
}

$(function() {
    initCharts();
    streamStats();
    streamStats2();
    streamStats3();
    streamStats4();
    $(window).resize( respondCanvas );
    respondCanvas();
});
