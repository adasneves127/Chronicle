using MySql.Data.MySqlClient;
using Chronicle.Controls;

namespace Chronicle
{
    public partial class Form1 : Form
    {
        public static string connectionString;
        public Form1()
        {
            if (Globals.currentEnvironment is null)
            {
                Application.Exit();
                return;
            }
            connectionString = Globals.currentEnvironment.getConnString().ConnectionString;
            InitializeComponent();

            populateMenu();
        }


        public void populateMenu()
        {
            using (MySqlConnection conn = new(connectionString))
            {
                MySqlCommand cmd = conn.CreateCommand();
                conn.Open();
                cmd.CommandText = "SELECT * FROM MENU_ITEMS WHERE parentID is null";
                MySqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    object winFormIDRaw = reader["winFormID"];
                    int winFormID = 0;
                    if (winFormIDRaw is not DBNull) winFormID = (int)winFormIDRaw;
                    NavigationItem itm = new(reader.GetString("label"), winFormID, this);
                    populateSubmenu(itm, reader.GetInt32("menuItemID"));
                    menuStrip1.Items.Add(itm);
                }
            }
        }

        public void populateSubmenu(ToolStripMenuItem parentItem, int parentID)
        {
            using (MySqlConnection conn = new(connectionString))
            {
                MySqlCommand cmd = conn.CreateCommand();
                conn.Open();
                cmd.CommandText = "SELECT * FROM MENU_ITEMS WHERE parentID = @parentID";
                cmd.Parameters.AddWithValue("@parentID", parentID);
                MySqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    object winFormIDRaw = reader["winFormID"];
                    int winFormID = 0;
                    if (winFormIDRaw is not DBNull) winFormID = (int)winFormIDRaw;
                    NavigationItem itm = new(reader.GetString("label"), winFormID, this);
                    populateSubmenu(itm, reader.GetInt32("menuItemID"));
                    parentItem.DropDownItems.Add(itm);
                }
            }
        }
    }
}
