using MySqlConnector;
using System.Collections.Generic;
using System.Xml;
using System;
using System.Diagnostics;
using System.IO;
using Chronicle.Utils;
using Microsoft.CodeAnalysis.VisualBasic.Syntax;

namespace Chronicle
{
    internal static class Program
    {
        static List<Environments> getConnections()
        {
            List<Environments> list = new();

#if DEBUG
            // This will get the current WORKING directory (i.e. \bin\Debug)
            string workingDirectory = Environment.CurrentDirectory;
            // or: Directory.GetCurrentDirectory() gives the same result

            // This will get the current PROJECT directory
            string projectDirectory = Directory.GetParent(workingDirectory).Parent.Parent.FullName;

            // Load from Project Directory Settings.xml
            XmlDocument doc = new XmlDocument();
            doc.Load(Path.Join(projectDirectory,"Settings.xml"));
            XmlNode node = doc.DocumentElement.SelectSingleNode("/settings/environments");
            foreach (XmlNode environment in node.ChildNodes)
            {
                string envName = "", dbName = "", dbHost = "";
                int dbPort = 0;
                bool selected = false;
                foreach (XmlNode envComponent in environment.ChildNodes)
                {
                    switch (envComponent.Name)
                    {
                        case "name":
                            envName = String.IsNullOrEmpty(envComponent.InnerText) ? "" : envComponent.InnerText;
                            break;
                        case "host":
                            dbHost = String.IsNullOrEmpty(envComponent.InnerText) ? "" : envComponent.InnerText;
                            break;
                        case "port":
                            dbPort = Int32.Parse(String.IsNullOrEmpty(envComponent.InnerText) ? "0" : envComponent.InnerText);
                            break;
                        case "schema":
                            dbName = String.IsNullOrEmpty(envComponent.InnerText) ? "" : envComponent.InnerText;
                            break;
                        case "selected":
                            selected = true;
                            break;
                        default:
                            throw new Exception("Unexpected element in Environment Settings.");
                    }
                }

                Environments env = new Environments(envName,dbName,dbHost,dbPort, selected);
                list.Add(env);
                // Debug.WriteLine(environment.ChildNodes.Count);
            }
#else
            // Load from AppData Directory Settings.xml
            throw new NotImplementedException();

#endif
            return list;
        }
        
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {

            List<Environments> conns = getConnections();

            ApplicationConfiguration.Initialize();


            Auth auth = new Auth(conns);
            DialogResult res = auth.ShowDialog();


            if (res == DialogResult.OK)
            {
                // Load the plugins!
                Globals.manager = new();
                Application.Run(new Form1());
            }
        }
    }
}