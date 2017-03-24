# Gigantic
Due to its nature, a wearable device can either provide limited functions, or disappointing battery life. However, the battery of a functional wearable device is not drain by carrying out functions, but by the display module, and the graphic function used to maintain a Graphic User Interface (GUI). Therefore, by changing the way we interact with wearable devices, we could balance between functionality and power consumption. 
This project is a voice command-orientated interface specialized for the calculation and limitation of wearable device. 

Because the time constraints, the introduction is not ready yet. Please reference to the PDF on any details of the project. 

# Special Design
---------
1. Dynamic Plugin

In traditional plugin design, objects from a plugin cannot be access by a separate plugin without exposing the memory, or load the second plugin to the process of the first plugin. This approach increase the risk to security and stability. The traditional plugin design, based on programming language, also require the programmers to gain access to the object strucutre prior to the develpmenet, which increase the dependency on the development process. 
In Gigantic, plugin behaviors for the knowledge graph plugin are defined in a XML file, which define the behavior of the plugin in query language, allowing it to be run on the plugin containing the object. 
It also support "alias" for key to value, which map multiple keys to the same variable. This allow developer to write the plugin logic closer to natural language, and user to use the interface with synonym. 

2. Sentence Strucutre Senstive

In traditional voice based user interface, the input analysts is usually handled by recurrent neural network, or keyword tagging. However, one important feature in human language is the redundacy between different layers: the spelling filter the error from pronounication, the word assoication filter the error in wording, and the sentence strucutre filter out homophones, and define the parsing structure. (For that, check out 30 Rock's epsiode on the game show "Homonym") By using the traditional approach, the sentence strucutre is vastly disregarded because of the polysemes in language, and the probability approach. 
In Gigantic, input are parse and analyse by the strucutre. It tries all the possible combination of the sentences, and pick the structure that is correct, and parse the sentences into a query strucutre. This approach could reject the homonym error from the existing speech recogition system, enable complex sentence strucuture, and simplify the speech recogition. 
