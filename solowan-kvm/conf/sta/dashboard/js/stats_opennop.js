var allTimeSeries = {};
var allValueLabels = {};
var descriptions = {
    'Optimizer 1: Decompressor': {
        'total_input_bytes_dec_1-2' : 'Number of bytes',
        'total_output_bytes_dec_1-2' : 'Number of bytes'
    },
    'Optimizer 2: Compressor': {
        'total_input_bytes_com_1-2' : 'Number of bytes',
        'total_output_bytes_com_1-2' : 'Number of bytes'
    },
    'Optimizer 1: Compressor': {
        'total_input_bytes_com_2-1' : 'Number of bytes',
        'total_output_bytes_com_2-1' : 'Number of bytes'
    },
    'Optimizer 2: Decompressor': {
        'total_input_bytes_dec_2-1' : 'Number of bytes',
        'total_output_bytes_dec_2-1' : 'Number of bytes'
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
                disabled: false, 
                fillStyle: '#ff8000',     // colour for text of labels,
                fontSize: 15,
                fontFamily: 'sans-serif',
                precision: 0
            },
            horizontalLines:[{color:'#880000',lineWidth:2,value:1250000}],
            maxValue:11000000
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
    $(window).resize( respondCanvas );
    respondCanvas();
});
