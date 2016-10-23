        var websocket;
        var dominio;
        var websocket2;
        var dominio2;

        function includeJs(jsFilePath) {
            var js = document.createElement("script");
            js.type = "text/javascript";
            js.src = jsFilePath;
            document.body.appendChild(js);
        }

        $(document).ready(function() {
                                
            websocket = new WebSocket('ws://10.250.0.6:8000/?script=script_opennop_comp.sh'); 
                                          
            websocket2 = new WebSocket('ws://10.250.0.2:8000/?script=script_opennop_decom.sh');
   
            dominio = 'ws://10.250.0.6:8000/?script=script_opennop_comp.sh';

            dominio2 = 'ws://10.250.0.2:8000/?script=script_opennop_decom.sh';
                                
            websocket.onopen = function() {
                //document.body.style.backgroundColor = '#cfc';
                console.log("conex abierta");
            };
            
            websocket.onclose = function() {
                //document.body.style.backgroundColor = null;
                console.log("conex cerrada");
            };
            websocket.onmessage = function(event) {
                //document.getElementById('textoAmostrar').innerText = event.data;
                console.log("evento recibido");
            };                                                    
                       
            websocket2.onopen = function() {
                //document.body.style.backgroundColor = '#cfc';
                console.log("conex abierta");
            };
            websocket2.onclose = function() {
                //document.body.style.backgroundColor = null;
                console.log("conex cerrada");
            };
            websocket2.onmessage = function(event) {
                //document.getElementById('textoAmostrar').innerText = event.data;
                console.log("evento recibido");
            };            
            
            includeJs("js/stats_opennop.js");
                                
        }); //      
