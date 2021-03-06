﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using OpenBveApi;
using OpenBveApi.Math;

namespace RouteBuilder
{






    public class RBProject
    {
        /// <summary>
        /// RB project name
        /// </summary>
        public string projectname;
        /// <summary>
        /// Author name
        /// </summary>
        public string author;
        /// <summary>
        /// Author email address
        /// </summary>
        public string author_email;
        /// <summary>
        /// Project description
        /// </summary>
        public string description;

        public string vmaxslowsignal;
        /// <summary>
        /// Route gauge in millimeters, i.e. 760, 1067, 1372, 1435 (default), 1524
        /// </summary>
        public int gauge;
        /// <summary>
        /// Safety system implementation
        /// </summary>
        public int change;

        //OpenBVE specific commands
        /// <summary>
        /// Acceleration gravity coefficient, default = 9.80665
        /// </summary>
        public double accelerationduetogravity;
        /// <summary>
        /// Height of the route above sea level, default = 0
        /// </summary>
        public double elevation;
        /// <summary>
        /// Temperature in degrees centigrade (Celsius), default = 20
        /// </summary>
        public int temperature;
        /// <summary>
        /// Athmospheric pressure in kPa (kilopascals), default = 101.325
        /// </summary>
        public double pressure;

        /// <summary>
        /// Light direction theta angle (vertical)
        /// </summary>
        public int lightdir_theta;
        /// <summary>
        /// Light direction phi angle (horizontal)
        /// </summary>
        public int lightdir_phi;


        public List<object> walls;
        public List<object> dikes;
        public List<object> grounds;
        public List<object> freeobjects;

        public List<RBStation> stations;

        public RBProject()
        {
            this.projectname = "";

            this.gauge = 1435;


            this.pressure = 101.325;
            this.temperature = 20;


            this.walls = new List<object>();
            this.dikes = new List<object>();
            this.grounds = new List<object>();
            this.stations = new List<RBStation>();

        }


        public RBStation GetStationByIndex(int index)
        {
            return this.stations[index];
        }

        public RBStation GetStationByName(string sname)
        {
            int i;
            RBStation st;
            for (i = 0; i < this.stations.Count; i++)
            {
                st = stations[i];
                if (st.stationname == sname)
                {
                    return st;
                }
                
            }
            return null;
        }

    }

    /// <summary>
    /// RB in-editor point
    /// </summary>
    public class RBPoint
    {

        public DoublePoint p;

        /// <summary>
        /// Point height (Z-level)
        /// </summary>
        public double height;
        /// <summary>
        /// Point ID
        /// </summary>
        public long id;



    }

    /// <summary>
    /// RB in-editor connection
    /// </summary>
    public class RBConnection
    {
        private RBPoint fp1;
        private RBPoint fp2;
        //=======================================================




        /// <summary>
        /// RB in-editor connection ID
        /// </summary>
        public int id;
        public int texture;

        /// <summary>
        /// Track speed limit, 0 - unlimited.
        /// </summary>
        public int speedlimit;
        /// <summary>
        /// RB in-editor height
        /// </summary>
        public double height;

        /// <summary>
        /// Track adhesion representing conditions. I.e. 135 for dry conditions, 85 - frosty, 50 - snowy, 0 - train can't move at all
        /// </summary>
        public uint adhesion;
        public uint accuracy;
        public int fog;


        public string polestype;
        public string background;
        public string ground;
        public string platformtype;

        public string rooftype;

        public string cracktype;

        public int brightness;

        public string announce_filename;
        public string announce_speed;

        public string doppler_filename;
        public double doppler_x;
        public double doppler_y;

        public bool buffer;
        
        /// <summary>
        /// Exported or no?
        /// </summary>
        public bool exported;


        public RBPoint p1
        {
            get
            {
                return fp1;
            }
            set
            {
                fp1 = p1;
            }
        }
        public RBPoint p2
        {
            get
            {
                return fp2;
            }
            set
            {
                fp2 = p2;
            }
        }


        public RBConnection(RBPoint p1, RBPoint p2)
        {
            this.p1 = fp1;
            this.p2 = fp2;

            this.id = 0;
            this.speedlimit = 0; //unlimited speed
            this.adhesion = 255; //perfect condition


        }
        public RBConnection(RBConnection from)
        {
            //this = new RBConnection(from.p1, from.p2);
        }



    }

    public class RBRouteDefinition : List<string>
    {

    }




    /// <summary>
    /// Represents a station in RouteBuilder
    /// </summary>
    public class RBStation : List<string>
    {
        public string stationname;
        public string arrivalsound;
        public string departuresound;
        public bool exported;
        public DoorSide doorside;
        public System system;
        public int minstoptime;
        public int passalarm;
        public int forcedredsignal;

        public bool change_ends;

        public RBStation(string name)
        {
            this.stationname = name;
            this.doorside = DoorSide.N;
            this.system = System.ATS;
            this.arrivalsound = "";
            this.departuresound = "";
            this.passalarm = 0;
            this.forcedredsignal = 0;
            this.change_ends = false;
        }

        public RBStation(string name, string asound, string dsound)
        {
            this.stationname = name;
            this.doorside = DoorSide.N;
            this.system = System.ATS;
            this.arrivalsound = asound;
            this.departuresound = dsound;
            this.passalarm = 0;
            this.forcedredsignal = 0;
            this.change_ends = false;
            
        }

        public RBStation(string name, DoorSide ds, System sys, string asound, string dsound, int pa, int frs, bool ce)
        {

        }


        /// <summary>
        /// Defines where doors should be opened
        /// </summary>
        public enum DoorSide
        {
            L,//left
            N,//no
            R,//right
            B//both

        }

        /// <summary>
        /// Defines what safety system would be used
        /// </summary>
        public enum System
        {
            ATS,
            ATC
        }

        /// <summary>
        /// Converts lettered door side values to numbered
        /// </summary>
        /// <param name="ds">The lettered door side value</param>
        /// <returns>The numbered door side value</returns>
        public int DoorSideToInt(DoorSide ds)
        {
            switch (ds)
            {
                case DoorSide.L:
                    return -1;
                case DoorSide.N:
                    return 0;
                case DoorSide.R:
                    return 1;
                case DoorSide.B:
                    return 0;
            }
            return 0;
        }

        /// <summary>
        /// Converts lettered system values to numbered
        /// </summary>
        /// <param name="s">The lettered system value</param>
        /// <returns>The numbered system value</returns>
        public int SystemToInt(System s)
        {
            switch (s)
            {
                case System.ATS:
                    return 0;
                case System.ATC:
                    return 1;
            }
            return 0;
        }



    }







    /// <summary>
    /// An export script.
    /// </summary>
    public class RBExport
    {
        protected bool fsmooth;

        /// <summary>
        /// List of ground textures (.b3d/.csv/.x file)
        /// </summary>
        protected List<string> groundtexturelist;

        /// <summary>
        /// List of track texture (.b3D/.csv/.x file)
        /// </summary>
        protected List<string> tracktexturelist;

        /// <summary>
        /// List of left walls (.b3d/.csv/.x file)
        /// </summary>
        protected List<string> leftwalllist;

        /// <summary>
        /// List of right walls (.b3d/.csv/.x file)
        /// </summary>
        protected List<string> rightwalllist;

        /// <summary>
        /// List of left dikes (.b3d/.csv/.x file)
        /// </summary>
        protected List<string> leftdikelist;

        /// <summary>
        /// List of right dikes (.b3d/.csv/.x file)
        /// </summary>
        protected List<string> rightdikelist;

        /// <summary>
        /// List of left cracks (.b3d/.csv/.x)
        /// </summary>
        protected List<string> leftcracklist;
        /// <summary>
        /// List of right cracks (.b3d/.csv/.x)
        /// </summary>
        protected List<string> rightcracklist;

        protected List<string> usedtrackobjects;
        protected List<string> usedgrounds;
        protected List<string> usedwalls;
        protected List<string> usedbackgrounds;
        protected List<string> usedfreeobj;
        protected List<string> usedplatforms;
        protected List<string> usedroofs;
        protected List<string> usedpoles;

        protected List<string> header;

        protected int startindex;
        protected int nextindex;


        public RBProject project;
        public string basepath;
        public string timetable;
        public List<string> exportfile;
        public RBStation nextstation;
        public List<string> passstations;


        public RBExport(bool smooth)
        {
            this.fsmooth = smooth;

        }


        /// <summary>
        /// Exports a route header section to CSV format
        /// </summary>
        /// <param name="exportinterface">The route code</param>
        public void ExportHeaderCSV(List<string> exportinterface)
        {
            //exportinterface.Add(";made with RouteBuilder");
            exportinterface.Add("With Route");
            exportinterface.Add(".Comment " + project.description + "$chr(13)$chr(10)");
            exportinterface.Add(".Change " + project.change.ToString());
            exportinterface.Add(".Gauge " + project.gauge.ToString());

            //expert mode checking


        }

        /// <summary>
        /// Exports a route header section to RW format
        /// </summary>
        /// <param name="exportinterface">The route code</param>
        public void ExportHeaderRW(List<string> exportinterface)
        {
            exportinterface.Add("[Route]");
            exportinterface.Add("Comment=" + project.description);
            exportinterface.Add("Change=" + project.change.ToString());
            exportinterface.Add("Gauge=" + project.gauge.ToString());
            
            //expert mode checking
            

        }

        /// <summary>
        /// Exports a route train section to CSV format
        /// </summary>
        /// <param name="exportinterface">The route code</param>
        /// <param name="train">The train name</param>
        public void ExportTrainCSV(List<string> exportinterface, string train)
        {
            exportinterface.Add("With Train");
            exportinterface.Add(".Folder " + train); //add folder of train

        }

        /// <summary>
        /// Exports a route train section to RW format
        /// </summary>
        /// <param name="exportinterface">The route code</param>
        /// <param name="train">The train name</param>
        public void ExportTrainRW(List<string> exportinterface, string train)
        {
            exportinterface.Add("[Train]");//start section
            exportinterface.Add("Folder=" + train);//add folder key

            //TODO: BVETSS 1.0 compliance or non-compliance (for non-standard routes)

        }


        public void ExportObjectsCSV(List<string> exportinterface)
        {
            int i;
            int j;
            int maxobjid;


            exportinterface.Add("With Structure");

            //export ground texture objects
            for (i = 0; i < groundtexturelist.Count; i++)
            {
                exportinterface.Add(".ground(" + groundtexturelist.IndexOf(groundtexturelist[i]) + ") " + groundtexturelist[i]);
            }

            //export rail texture objects
            for (i = 0; i < tracktexturelist.Count; i++)
            {
                exportinterface.Add(".rail(" + tracktexturelist.IndexOf(tracktexturelist[i]) + ") " + tracktexturelist[i]);
            }

            //export walls and dikes
            //Please note that left and right walls and dikes will be exported separately

            //exporting left walls
            for (i = 0; i < leftwalllist.Count; i++)
            {
                exportinterface.Add(".wallL(" + leftwalllist.IndexOf(leftwalllist[i]) + ") " + tracktexturelist[i]);
            }
            //exporting right walls
            for (i = 0; i < rightwalllist.Count; i++)
            {
                exportinterface.Add(".wallR(" + rightwalllist.IndexOf(rightwalllist[i]) + ") " + tracktexturelist[i]);
            }
            //exporting left dikes
            for (i = 0; i < leftdikelist.Count; i++)
            {
                exportinterface.Add(".dikeL(" + leftdikelist.IndexOf(leftdikelist[i]) + ") " + leftdikelist[i]);
            }
            //exporting right dikes
            for (i = 0; i < rightdikelist.Count; i++)
            {
                exportinterface.Add(".dikeR(" + rightdikelist.IndexOf(rightdikelist[i]) + ") " + rightdikelist[i]);
            }
            
            //exporting cracks
            //Please note that left and right cracks will be exported separately.
            //exporting left cracks
            for (i = 0; i < leftcracklist.Count; i++)
            {
                exportinterface.Add(".crackL(" + leftcracklist.IndexOf(leftcracklist[i]) + ") " + leftcracklist[i]);
            }
            //exporting right cracks
            for (i = 0; i < rightcracklist.Count; i++)
            {
                exportinterface.Add(".crackR(" + rightcracklist.IndexOf(rightcracklist[i]) + ") " + rightcracklist[i]);
            }


        }




        /// <summary>
        /// Export stations in CSV format
        /// </summary>
        public void ExportStationCSV()
        {
            RBStation station;
            bool pass;
            bool change_ends;
            for (int i = 0; i < project.stations.Count; i++)
            {
                station = project.GetStationByIndex(i);

                if (nextstation == station)
                {

                }
                //setting up whether to pass or to stop
                pass = (passstations.IndexOf(station.stationname) >= 0);
                //setting up whether to change ends or not
                change_ends = station.change_ends;



            }
        }


        public void ExportTrackCSV(List<string> exportinterface)
        {
            exportinterface.Add("With Track");


            


        }





    }
}
