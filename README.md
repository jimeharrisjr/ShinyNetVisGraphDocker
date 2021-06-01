# ShinyNetVisGraphDocker
This is  Docker implementation of the Shiny Network Visualization app:
( https://github.com/jimeharrisjr/ShinyNetVisGraph )
The pre-built version for Raspberry Pi (ARM-32) is avilable on Docker.io
`docker run -d --network local jimeharrisjr/pcapgraph`
Then navigate your browser to http://127.0.0.1:8080
This repository can be cloned and altered to make your own custom verion.

*NOTE* This dockerfile begins from an imgage built for RasPi. 
For other systems, use the appropriate Rocker image (https://hub.docker.com/r/rocker/rstudio )

This is a simple tool using the visnetwork package (<https://datastorm-open.github.io/visNetwork/>) to with Shiny and Shinydashboard to visualize live packet capture data from a network interface using **Rtins**

The **Rtins** package provides tools for analysing network captures in R on top of [`libtins`](http://libtins.github.io), a high-level, multiplatform C++ network packet decoding and crafting library.



You will be presented with a dashboard with two tabs on the left, "Visualize"" and "Data" From "Visualize," click the "Go" button. After a short time, you should see a graph being drawn. Hit "Stop" to interrupt the collection, and "Reset" to clear the collection and start again.

You can click on a network node to highlight it and its nearest neighbors. You can also click and hold to drag nodes arround to rearrange them.

From the "Data" tab, you can see the capured data in tabular format. The table is interactive: you can sort columns from the top of the table, and search them from the bottom of each column. There is an all-fields search at the top of the table frame.
