using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Chronicle.Utils;
using MySql.Data;
using MySql.Data.MySqlClient;

namespace Chronicle
{
    public partial class Auth : Form
    {
        private List<Environments> _environments;
        public Auth(List<Environments> conns)
        {
            _environments = conns;
            InitializeComponent();
            foreach (Environments environment in _environments)
            {
                int index = comboBox1.Items.Add(environment.envName);
                if (environment.selected)
                {
                    comboBox1.SelectedIndex = index;
                }
            };
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Debug.WriteLine(comboBox1.Text);

            // Try to connect.
            foreach (Environments environment in _environments)
            {
                environment.selected = false;
                if (environment.envName == comboBox1.Text)
                {
                    environment.selected = true;
                    MySqlConnectionStringBuilder csb = environment.getConnString();
                    csb.UserID = txtUserID.Text;
                    csb.Password = txtPassword.Text;
                    MySqlConnection conn = new MySqlConnection();
                    conn.ConnectionString = csb.ConnectionString;
                    try
                    {
                        conn.Open();

                        conn.Close();
                        environment.set_credentials(txtUserID.Text, txtPassword.Text);
                        Globals.currentEnvironment = environment;
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show(ex.ToString(), ex.GetType().ToString(), MessageBoxButtons.OK);
                        this.DialogResult = DialogResult.Abort;
                        return;
                    }
                }
            };
            this.DialogResult = DialogResult.OK;

        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Abort;
            // this.Close();
        }
    }
}
