(()=>{

// subsetting code from plotly.R, with some modifications

let subsetArray = (arr, indices) => indices.map(i => arr[i]);

function subsetArrayAttrs(obj, indices) {
    let newObj = {};
    for(let k in obj) {
        let val = obj[k];
        
        if (k.charAt(0) === "_") {
            newObj[k] = val;
        } else if (k === "transforms" && Array.isArray(val)) {
            newObj[k] = val.map(transform => subsetArrayAttrs(transform, indices));
        } else if (k === "colorscale" && Array.isArray(val)) {
            newObj[k] = val;
        } else if (Array.isArray(val)) {
            newObj[k] = subsetArray(val, indices);
        } else {
            newObj[k] = val;
        }
    }    
    return newObj;
}


HTMLWidgets.widget({
    name: 'talkToPlotly',
    type: 'output',
    
    factory: function(el, width, height) {
        let traces = [ ], layout = { }, config = { };
        let firstTime = true;
        let selectionHandles = { };
        let filterHandles = { };
        
        function updateHandles() {
            for(let name in selectionHandles)
                selectionHandles[name].close();
                
            for(let name in filterHandles)
                filterHandles[name].close();
            
            selectionHandles = { };
            filterHandles = { };
            for(let i=0;i<traces.length;i++) {
                if (!Object.hasOwn(traces[i],'set')) continue;
                if (Object.hasOwn(selectionHandles,traces[i].set)) continue;
                
                let sel = new crosstalk.SelectionHandle();
                sel.setGroup(traces[i].set);
                sel.on("change", updateIn);
                selectionHandles[traces[i].set] = sel;
                
                let fil = new crosstalk.FilterHandle();
                fil.setGroup(traces[i].set);
                fil.on("change", updateIn);
                filterHandles[traces[i].set] = fil;
            }
            
            updateIn();
        }
        
        function updateIn() {
            let selSets = { };
            for(let name in selectionHandles)
                selSets[name] = new Set(selectionHandles[name].value);
            
            let filSets = { };
            for(let name in filterHandles)
                filSets[name] = new Set(filterHandles[name].filteredKeys);
            
            let newTraces = [ ];
            for(let i=0;i<traces.length;i++) {
                let trace = { ...traces[i] };
                if (Object.hasOwn(trace,"set")) {
                    let filSet = filSets[trace.set];
                    if (filSet.size) {
                        let indices = [ ];
                        for(j=0;j<trace.key.length;j++)
                            if (filSet.has(trace.key[j]))
                                indices.push(j);
                        trace = subsetArrayAttrs(trace, indices);
                    }
                    
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
            
            Plotly.react(el, newTraces, layout, config);
            if (firstTime) {
                //el.on("plotly_selecting", onSelectionChange);
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
                let trace = el.data[item.curveNumber]; //Use data in element, which is filtered
                if (!trace.hasOwnProperty("set")) continue;
                selSets[trace.set].add( trace.key[item.pointNumber] );
            }
            
            for(let name in selSets) {
                if (selSets[name].size == 0)
                    selectionHandles[name].clear();
                else
                    selectionHandles[name].set(Array.from(selSets[name]));
            }
            
            // Can be necessary to clear box and faded points on empty selection
            if (!eventData || !eventData.points.length)
                updateIn();
        }
        
        return {
            renderValue: function(x) {
                traces = x.data;
                layout = x.layout;
                config = x.config;
                updateHandles();
            },
            
            resize: function(width, height) {
                // TODO: code to re-render the widget with a new size
            }
        };
    }
});


})();