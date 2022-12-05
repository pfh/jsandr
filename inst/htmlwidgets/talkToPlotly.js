HTMLWidgets.widget({
    
    name: 'talkToPlotly',
    
    type: 'output',
    
    factory: function(el, width, height) {
        let traces = [ ], layout = { }, config = { };
        let firstTime = true;
        let selectionHandles = { };
        
        function updateHandles() {
            for(let name in selectionHandles)
                selectionHandles[name].close();
            
            selectionHandles = { };
            for(let i=0;i<traces.length;i++) {
                if (traces[i].set === undefined) continue;
                let sel = new crosstalk.SelectionHandle();
                sel.setGroup(traces[i].set);
                sel.on("change", updateIn);
                selectionHandles[traces[i].set] = sel;
            }
        }
        
        function updateIn() {
            console.log("in");
            let selSets = { };
            for(let name in selectionHandles)
                selSets[name] = new Set(selectionHandles[name].value);
            
            let newTraces = [ ];
            for(let i=0;i<traces.length;i++) {
                let trace = { ...traces[i] };
                if (trace.hasOwnProperty("set")) {
                    let selSet = selSets[trace.set];
                    if (selSet.size) {
                        trace.selectedpoints = [ ];
                        for(j=0;j<trace.key.length;j++)
                            if (selSet.has(trace.key[j]))
                                trace.selectedpoints.push(j);
                    } else {
                        delete trace.selectedpoints;
                    }
                }
                newTraces.push(trace);
            }
            traces = newTraces;

            Plotly.react(el, traces, layout, config);
            if (firstTime) {
                el.on("plotly_selected", onSelectionChange);
                el.on("plotly_deselect", onSelectionChange);
            }
            firstTime = false;
        }
        
        function onSelectionChange(eventData) {
            let selSets = { };
            for(let name in selectionHandles)
                selSets[name] = new Set();
            
            if (eventData)
            for(let item of eventData.points) {
                let trace = traces[item.curveNumber];
                if (!trace.hasOwnProperty("set")) continue;
                selSets[trace.set].add( trace.key[item.pointNumber] );
            }
            
            for(let name in selSets) {
                if (selSets[name].size == 0)
                    selectionHandles[name].clear();
                else
                    selectionHandles[name].set(Array.from(selSets[name]));
            }
        }
        
        return {
            renderValue: function(x) {
                traces = x.data;
                layout = x.layout;
                config = x.config;
                updateHandles();
                updateIn();
            },
            
            resize: function(width, height) {
                // TODO: code to re-render the widget with a new size
            }
        };
    }
});
