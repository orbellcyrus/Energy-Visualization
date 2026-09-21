import java.util.HashMap;

HashMap<String, Integer> colorMap = new HashMap<String, Integer>();


boolean pieMode = true;
boolean useCategories = true;
boolean useRegions = false;

//Top 32 most populated countries with data
StringList countryCodesPie = new StringList("IND", "CHN", "USA", 
"IDN", "PAK", "BRA", "BGD", "RUS", "MEX", "JPN", 
"EGY", "PHL", "VNM", "IRN", "TUR", "DEU", "THA", "GBR", "FRA",
 "ZAF", "ITA", "COL", "KOR", "DZA", "IRQ", "ESP", "ARG", "CAN", 
 "UKR", "MAR", "POL","UZB");


StringList countryCodesBar = new StringList("DZA","ARG","AUS","AUT","AZE","BGD","BLR","BEL","BRA","BGR","CAN","CHL","CHN","COL","HRV","CYP","CZE","DNK","ECU","EGY","EST","FIN","FRA","DEU","GRC","HKG","HUN","ISL","IND","IDN","IRN","IRQ","IRL","ISR","ITA","JPN","KAZ","KWT","LVA","LTU","LUX","MYS","MEX","MAR","NLD","NZL","MKD","NOR","OMN","PAK","PER","PHL","POL","PRT","QAT","ROU","RUS","SAU","SGP","SVK","SVN","ZAF","KOR","ESP","LKA","SWE","CHE","TWN","THA","TTO","TUR","TKM","USSR","UKR","ARE","GBR","USA","UZB","VEN","VNM");

StringList worldRegions = new StringList("OWID_NAM","OWID_AFR","OWID_EUR","OWID_EU27","OWID_HIC","OWID_LMC","OWID_OCE","OWID_SAM","OWID_UMC","OWID_WRL");//Low income countries have no data
Table data;

//this is not optimal 
String chartStyleText = "Change to Line Graph";
String groupEnergyText = "Split Categories";
String useRegionsText = "Use World Regions";

FloatDict countryHighestEnergyLookupTable;
HashMap<String, RowOfSources> countryYearRowLookup;

PFont titleFont;
PFont labelFont;

int graphWidth;
int graphBottom;;
int graphTop = 50;
int graphLeftSide = 100;
int minYear = 1965;
int maxYear = 2024;
int selectedYear = 2024;



float sliderX ;
float sliderY ;
float sliderWidth ;
boolean draggingSlider = false;

StringList barChartCountries = new StringList("BRA","FRA","CHN","USA");

void setup(){
    size(1200, 600);
    graphWidth = width -150;
    graphBottom =  height -100;
    sliderX = graphLeftSide + 50;
    sliderY = 550;
    sliderWidth = graphWidth-graphLeftSide - 100;

    labelFont = createFont("SansSerif", 14);

    colorMap.put("renewables", color(154, 232, 237));
    colorMap.put("fossils" , color(50));
    colorMap.put("nuclear" , color(44, 250, 31));
    colorMap.put("other renewables" , color(255, 0, 162));
    colorMap.put("biofuels" , color(251, 236, 93));
    colorMap.put("solar", color(252, 229, 112));
    colorMap.put("wind", color(230));
    colorMap.put("hydro", color(12, 58, 145));
    colorMap.put("gas", color(166, 116, 162));
    colorMap.put("oil", color(255, 191, 0));
    colorMap.put("coal", color(50));

    textFont(labelFont);
    data = loadTable("energy-mix.csv", "header");
    countryHighestEnergyLookupTable = new FloatDict();
    countryYearRowLookup = new HashMap<String, RowOfSources>();

    for(TableRow row : data.rows()){
        String code = row.getString("code");
        if(code != null && !code.equals("")){
            RowOfSources rowofsources = new RowOfSources(row.getString("entity"),row.getFloat("other_renewables_twh"),row.getFloat("biofuels_twh"),
            row.getFloat("solar_twh"),row.getFloat("wind_twh"),row.getFloat("hydro_twh"),
            row.getFloat("nuclear_twh"),row.getFloat("gas_twh"),row.getFloat("oil_twh"), row.getFloat("coal_twh"));
            countryYearRowLookup.put(code + "_" + row.getInt("year"),rowofsources );
        }
    }
    // finds the highest energy output ever for each country
    for(String code : countryCodesBar){
        println(code);
        float largest = 0;
        for(int year = 1965;year<2025;year++){
            RowOfSources currentRow = countryYearRowLookup.get(code+"_"+year);
            if(currentRow!=null){
                float sum = getTotalEnergy(currentRow);
                if(sum>largest) largest = sum;
            }

        }
        countryHighestEnergyLookupTable.set(code, largest);
    }
}

    

void draw(){
    background(255);

    stroke(0);
    line(graphWidth,0,graphWidth,height);
    
    //title
    fill(0);
    textAlign(CENTER,CENTER);
    text("Energy Produced By Type",graphWidth/2,10);

    //key
    fill(255);
    int keyColorsY = 25;
    rect(graphWidth+10,20,width - graphWidth -30, 150);
    for(String energyType : colorMap.keySet()){
        if(useCategories){
            if(energyType == "fossils" || energyType == "renewables" || energyType == "nuclear"){
                noStroke();
                fill(colorMap.get(energyType));
                rect(graphWidth+12,keyColorsY,7,7);
                fill(0);
                textAlign(LEFT,CENTER);
                text(energyType, graphWidth + 20, keyColorsY+3);
                keyColorsY += 10;

            }
        }else{
            if(!(energyType == "fossils") &&  !(energyType == "renewables")){
                noStroke();
                fill(colorMap.get(energyType));
                rect(graphWidth+12,keyColorsY,7,7);
                fill(0);
                textAlign(LEFT,CENTER);
                text(energyType, graphWidth + 20, keyColorsY+3);
                keyColorsY += 10;

            }
        }
        
        
    }
    stroke(0);
    
    
    
    
    textAlign(CENTER, CENTER);
    //buttons
    fill(0);
    rect(width -140 , 200, 120, 40);
    fill(255);
    text(chartStyleText,width-80 , 200+20);
    
    fill(0);
    rect(width -130 , 250, 100, 40);
    fill(255);
    text(groupEnergyText,width -80, 250+20);
    
    if(pieMode){
        fill(0);
        rect(width -130 , 300, 100, 40);
        fill(255);
        text(useRegionsText,width -80, 300+20);
    }else{
        fill(0);
        text("select up to 8 countries",graphWidth+((width-graphWidth)/2),300);
        int x  = graphWidth;
        int y = 310;
        for(String code : countryCodesBar){
            if(barChartCountries.hasValue(code)){
                fill(100,255,30);
            }else{
                fill(255);
            }
            
            rect(x,y,30,15);
            textAlign(CENTER, CENTER);
            fill(0);
            text(code,x+12,y+7);
            
            if(x== graphWidth+120){
                x = graphWidth;
                y = y+15;
            }else{
                x=x+30;
            }
        }
        fill(0);
        
    }
    
   

    //main graphics
    if(pieMode){
        drawYearSlider();
        int x = graphLeftSide+110;
        int y = graphTop+50;

            for(String code : useRegions ? worldRegions : countryCodesPie){ 
                RowOfSources row = countryYearRowLookup.get(code+"_"+selectedYear);
                if(row!=null){
                    PieChart piechart = new PieChart(row.otherRenewables,row.bioFuels,
                        row.solar,row.wind,row.hydro,row.nuclear,row.gas,row.oil,
                        row.coal,x,y,row.entity,useCategories);

                    piechart.display();
                }
                
                if(useRegions){
                     x+= 220 ;
                } else{
                    x+=110;
                }
                
                if(x>graphWidth){
                    x=graphLeftSide+110;
                    y+= 112;
                }

            }      
    }else{
        //these were going to be for interation but i think its too much for the user
        int year1 = 1965;
        int year2 = 2024;
        
        float highest = getHighestAmount(barChartCountries);
        line(graphLeftSide,graphBottom,graphLeftSide,graphTop);
        textAlign(LEFT,BOTTOM);
        text("Energy produced in Terrawatt Hours",2,graphTop);
        for(float i = 0; i < highest; i+=highest/5){
            float mappedy = map(i,0.0,highest,float(graphBottom),float(graphTop));
            line(graphLeftSide-25,mappedy,graphWidth,mappedy) ;
            textAlign(RIGHT,CENTER);
            text(i,graphLeftSide-26,mappedy);
        }

        for(int year = year1; year < year2; year+=4){
            int countryPosition = 0;
            float mappedX = map(year,1965,2024,graphLeftSide,graphWidth);
            for(String code : barChartCountries){
                RowOfSources row = countryYearRowLookup.get(code + "_" + year);
                if(row != null){
                    Bar bar = new Bar(row.otherRenewables,row.bioFuels,
                        row.solar,row.wind,row.hydro,row.nuclear,row.gas,row.oil,
                        row.coal,mappedX+countryPosition,graphBottom,graphTop,highest,code,useCategories);
                    bar.display();
                }
                countryPosition+=6; 
            }
            fill(0);
            textAlign(CENTER,CENTER);

            text(year,mappedX+barChartCountries.size()*2,graphBottom+30);
        }

    }     
}




void mousePressed() {
    if (mouseX > width - 130  && mouseX < width-30 && mouseY > 200 && mouseY < 240) {
        pieMode = !pieMode;
        if (chartStyleText.equals("Change to Line Graph")){
            chartStyleText = "Change to Pie Chart";
        }else{
            chartStyleText = "Change to Line Graph";
        }
    }

    if (mouseX > width - 130  && mouseX < width-30 && mouseY > 250 && mouseY < 290) {
        useCategories = !useCategories;
        if (groupEnergyText.equals("Split Categories")){
            groupEnergyText = "Group Categories";
        }else{
            groupEnergyText = "Split Categories";
        }
    }

    if(pieMode && (mouseX > width - 130  && mouseX < width-30 && mouseY > 300 && mouseY < 340)){
        useRegions = !useRegions;
        if (useRegionsText.equals("Use World Regions")){
            useRegionsText = "Use Countries";
        }else{
            useRegionsText = "Use World Regions";
        }
        
    }
    if(!pieMode){
        int makeCountryButtonsx  = graphWidth;
        int makeCountryButtonsy = 310;
        for(String code : countryCodesBar){
            if (mouseX > makeCountryButtonsx  && mouseX < makeCountryButtonsx+30 && mouseY > makeCountryButtonsy && mouseY < makeCountryButtonsy+15){
                if(barChartCountries.hasValue(code)){
                    barChartCountries.removeValue(code);
                }else{
                    if(barChartCountries.size()<8)barChartCountries.append(code);
                }    
                
            }
            if(makeCountryButtonsx== graphWidth+120){
                makeCountryButtonsx = graphWidth;
                makeCountryButtonsy = makeCountryButtonsy+15;
            }else{
                makeCountryButtonsx=makeCountryButtonsx+30;
            }

        }
    }
    

    float knobX = map(
    selectedYear,
    minYear, maxYear,
    sliderX, sliderX + sliderWidth
    );

    // Check if mouse is near the slider knob
    if (dist(mouseX, mouseY, knobX, sliderY) < 20) {
        draggingSlider = true;
    }
  
}

void mouseDragged() {
    if (draggingSlider) {
        float constrainedX = constrain(
        mouseX,
        sliderX,
        sliderX + sliderWidth
        );

        selectedYear = round(map(
        constrainedX,
        sliderX, sliderX + sliderWidth,
        minYear, maxYear
        ));
    }
 
}

void mouseReleased() {
    draggingSlider = false;
}


float getTotalEnergy(RowOfSources row){
    return row.otherRenewables +
           row.bioFuels +
           row.solar +
           row.wind +
           row.hydro +
           row.nuclear +
           row.gas +
           row.oil +
           row.coal;
}

float getHighestAmount(StringList codes){
    float highest = 0;
    for(String code : codes){
        float amount = countryHighestEnergyLookupTable.get(code);
        if(amount > highest) highest = amount;
    }
    return highest;
}

void drawYearSlider() {

  // Slider track
  stroke(150);
  strokeWeight(5);
  line(sliderX, sliderY,
       sliderX + sliderWidth, sliderY);

  // Position of the knob based on selected year
  float knobX = map(
    selectedYear,
    minYear, maxYear,
    sliderX, sliderX + sliderWidth
  );

  // Knob
  strokeWeight(1);
  fill(0, 150, 255);
  ellipse(knobX, sliderY, 20, 20);

  // Year label
  fill(0);
  textSize(18);
  textAlign(CENTER, CENTER);
  text(selectedYear, knobX, sliderY - 30);
}
