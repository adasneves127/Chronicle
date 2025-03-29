using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Chronicle.Controls
{
    public class NavigationItem : ToolStripMenuItem
    {
        private int winFormID;
        private Form parent;
        public NavigationItem(string Text, int? winFormID, Form parent)
        {
            this.Text = Text;

            if (winFormID is null) this.winFormID = 0;
            else this.winFormID = (int)winFormID;

            this.Click += onNavItemClick;
            this.parent = parent;
        }

        private void onNavItemClick(object sender, EventArgs e)
        {
            if (this.winFormID == 0) return;
            Globals.manager.ExecutePlugin(this.winFormID, parent);
        }
    }
}
