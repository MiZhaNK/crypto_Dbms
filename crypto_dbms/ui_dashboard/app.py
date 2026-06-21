import customtkinter as ctk
from tkinter import messagebox
from db_controller import DBController
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

# Set up modern theme
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class CryptoApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("CryptoExchange DBMS Dashboard")
        self.geometry("1100x700")
        
        self.db = DBController()
        
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)

        # ---------------------------------------------------------------------
        # SIDEBAR
        # ---------------------------------------------------------------------
        self.sidebar_frame = ctk.CTkFrame(self, width=200, corner_radius=0)
        self.sidebar_frame.grid(row=0, column=0, sticky="nsew")
        self.sidebar_frame.grid_rowconfigure(5, weight=1)

        self.logo_label = ctk.CTkLabel(self.sidebar_frame, text="CryptoDB Admin", font=ctk.CTkFont(size=20, weight="bold"))
        self.logo_label.grid(row=0, column=0, padx=20, pady=(20, 10))

        self.btn_dashboard = ctk.CTkButton(self.sidebar_frame, text="Analytics Dashboard", command=lambda: self.select_tab("dashboard"))
        self.btn_dashboard.grid(row=1, column=0, padx=20, pady=10)

        self.btn_wallets = ctk.CTkButton(self.sidebar_frame, text="Live Wallets", command=lambda: self.select_tab("wallets"))
        self.btn_wallets.grid(row=2, column=0, padx=20, pady=10)

        self.btn_transfer = ctk.CTkButton(self.sidebar_frame, text="Execute Transfer", command=lambda: self.select_tab("transfer"))
        self.btn_transfer.grid(row=3, column=0, padx=20, pady=10)

        self.btn_currencies = ctk.CTkButton(self.sidebar_frame, text="Live Currencies", command=lambda: self.select_tab("currencies"))
        self.btn_currencies.grid(row=4, column=0, padx=20, pady=10)

        self.btn_create_wallet = ctk.CTkButton(self.sidebar_frame, text="Create Wallet", command=lambda: self.select_tab("create_wallet"))
        self.btn_create_wallet.grid(row=5, column=0, padx=20, pady=10)

        self.btn_manage_users = ctk.CTkButton(self.sidebar_frame, text="Manage Users", command=lambda: self.select_tab("manage_users"))
        self.btn_manage_users.grid(row=6, column=0, padx=20, pady=10)

        self.status_label = ctk.CTkLabel(self.sidebar_frame, text="DB Status: Disconnected", text_color="red")
        self.status_label.grid(row=7, column=0, padx=20, pady=20, sticky="s")

        # ---------------------------------------------------------------------
        # MAIN CONTENT FRAME
        # ---------------------------------------------------------------------
        self.main_frame = ctk.CTkFrame(self, corner_radius=10)
        self.main_frame.grid(row=0, column=1, padx=20, pady=20, sticky="nsew")

        self.connect_to_db()

        self.tabs = {}
        self.setup_dashboard_tab()
        self.setup_wallets_tab()
        self.setup_transfer_tab()
        self.setup_currencies_tab()
        self.setup_create_wallet_tab()
        self.setup_manage_users_tab()

        self.select_tab("dashboard")

    def connect_to_db(self):
        success, msg = self.db.connect()
        if success:
            self.status_label.configure(text="DB Status: Connected", text_color="green")
        else:
            self.status_label.configure(text="DB Status: Offline", text_color="red")

    def select_tab(self, tab_name):
        for name, frame in self.tabs.items():
            frame.grid_forget()
        self.tabs[tab_name].grid(row=0, column=0, sticky="nsew", padx=20, pady=20)
        
        if tab_name == "dashboard":
            self.refresh_dashboard()
        elif tab_name == "wallets":
            self.refresh_wallets()
        elif tab_name == "currencies":
            self.refresh_currencies()

    def setup_dashboard_tab(self):
        frame = ctk.CTkFrame(self.main_frame, fg_color="transparent")
        frame.grid_columnconfigure(0, weight=1)
        frame.grid_rowconfigure(1, weight=1)
        self.tabs["dashboard"] = frame

        title = ctk.CTkLabel(frame, text="Analytics Dashboard (Live from MV)", font=ctk.CTkFont(size=24, weight="bold"))
        title.grid(row=0, column=0, pady=(0, 20), sticky="w")
        
        self.chart_frame = ctk.CTkFrame(frame)
        self.chart_frame.grid(row=1, column=0, sticky="nsew")
        self.canvas_widget = None

    def refresh_dashboard(self):
        self.db.call_procedure("DBMS_MVIEW.REFRESH", ["MONTHLY_TXN_TRENDS"])
        success, result = self.db.execute_query("SELECT txn_month, total_volume, total_fees FROM MONTHLY_TXN_TRENDS ORDER BY txn_month")
        
        if self.canvas_widget:
            self.canvas_widget.get_tk_widget().destroy()

        if success and result[1]:
            columns, rows = result
            months = [row[0] for row in rows]
            volumes = [row[1] for row in rows]
            
            fig, ax = plt.subplots(figsize=(8, 5), facecolor='#2b2b2b')
            ax.set_facecolor('#2b2b2b')
            ax.bar(months, volumes, color='#3b82f6')
            
            ax.set_title("Monthly Transaction Volume", color='white', fontsize=14)
            ax.set_xlabel("Month", color='white')
            ax.set_ylabel("Total Volume (Crypto)", color='white')
            ax.tick_params(colors='white')
            for spine in ax.spines.values():
                spine.set_color('#555555')

            self.canvas_widget = FigureCanvasTkAgg(fig, master=self.chart_frame)
            self.canvas_widget.draw()
            self.canvas_widget.get_tk_widget().pack(fill="both", expand=True)
        else:
            lbl = ctk.CTkLabel(self.chart_frame, text="No Data Available in MONTHLY_TXN_TRENDS")
            lbl.pack(pady=50)

    def setup_wallets_tab(self):
        frame = ctk.CTkFrame(self.main_frame, fg_color="transparent")
        frame.grid_columnconfigure(0, weight=1)
        frame.grid_rowconfigure(1, weight=1)
        self.tabs["wallets"] = frame

        title = ctk.CTkLabel(frame, text="Wallet Balances", font=ctk.CTkFont(size=24, weight="bold"))
        title.grid(row=0, column=0, pady=(0, 20), sticky="w")
        
        self.wallets_scroll = ctk.CTkScrollableFrame(frame, fg_color="transparent")
        self.wallets_scroll.grid(row=1, column=0, sticky="nsew")
        self.wallets_scroll.grid_columnconfigure(0, weight=1)

    def refresh_wallets(self):
        self.db.call_procedure("DBMS_MVIEW.REFRESH", ["WALLET_BALANCE_SUMMARY"])
        success, result = self.db.execute_query("SELECT user_id, wallet_id, balance, cryptocurrency, total_fiat_value FROM WALLET_BALANCE_SUMMARY ORDER BY total_fiat_value DESC")
        
        for widget in self.wallets_scroll.winfo_children():
            try:
                widget.destroy()
            except Exception:
                pass

        if success and result[1]:
            for row in result[1]:
                user_id, wallet_id, balance, symbol, fiat = row
                
                card = ctk.CTkFrame(self.wallets_scroll,corner_radius=15,border_width=1,border_color="#333333")
                card.grid(row=len(self.wallets_scroll.winfo_children()),column=0,sticky="ew",padx=20,pady=10)
                card.grid_columnconfigure(1, weight=1)
                
                # icon = ctk.CTkLabel(card, text="💼", font=ctk.CTkFont(size=20))
                # icon.grid(row=0, column=0, padx=40, pady=40, rowspan=3)
                
                lbl_title = ctk.CTkLabel(card, text=f"Wallet #{wallet_id} (User {user_id})", font=ctk.CTkFont(size=13, weight="bold"))
                lbl_title.grid(row=0, column=1, sticky="w", pady=(30, 10), padx=(10, 20))

                lbl_crypto = ctk.CTkLabel(card, text=f"Crypto: {balance:,.4f} {symbol}", font=ctk.CTkFont(size=14), text_color="#f59e0b")
                lbl_crypto.grid(row=1, column=1, sticky="w", pady=10, padx=(10, 20))
                
                lbl_fiat = ctk.CTkLabel(card, text=f"Fiat Value: ${fiat:,.2f}", font=ctk.CTkFont(size=10, weight="bold"), text_color="#10b981")
                lbl_fiat.grid(row=2, column=1, sticky="w", pady=(10, 30), padx=(10, 20))
        else:
            error_msg = result if not success else "No Wallet Data Available"
            lbl = ctk.CTkLabel(self.wallets_scroll, text=f"Data Error: {error_msg}", text_color="red")
            lbl.pack(pady=50)

    def setup_currencies_tab(self):
        frame = ctk.CTkFrame(self.main_frame, fg_color="transparent")
        frame.grid_columnconfigure(0, weight=1)
        frame.grid_rowconfigure(1, weight=1)
        self.tabs["currencies"] = frame

        title = ctk.CTkLabel(frame, text="Live Crypto Markets", font=ctk.CTkFont(size=24, weight="bold"))
        title.grid(row=0, column=0, pady=(0, 20), sticky="w")
        
        self.currencies_scroll = ctk.CTkScrollableFrame(frame, fg_color="transparent")
        self.currencies_scroll.grid(row=1, column=0, sticky="nsew")
        self.currencies_scroll.grid_columnconfigure(0, weight=1)

    def refresh_currencies(self):
        query = """
            SELECT 
                c.coin_id, 
                c.symbol, 
                c.coin_name, 
                c.current_price_usd, 
                c.market_cap,
                (SELECT price_usd FROM (
                    SELECT price_usd FROM price_history ph 
                    WHERE ph.coin_id = c.coin_id 
                    ORDER BY recorded_at DESC
                ) WHERE ROWNUM = 1) AS last_price
            FROM CRYPTOCURRENCIES c 
            ORDER BY c.market_cap DESC
        """
        success, result = self.db.execute_query(query)
        
        for widget in self.currencies_scroll.winfo_children():
            try:
                widget.destroy()
            except Exception:
                pass

        if success and result[1]:
            for row in result[1]:
                coin_id, symbol, coin_name, price, mcap, last_price = row
                
                fluctuation = ""
                price_color = "#10b981"
                if last_price is not None:
                    if price > last_price:
                        fluctuation = " ▲"
                        price_color = "#10b981"
                    elif price < last_price:
                        fluctuation = " ▼"
                        price_color = "#ef4444"
                    else:
                        fluctuation = " ➖"
                        price_color = "gray"
                
                card = ctk.CTkFrame(self.currencies_scroll, corner_radius=15, border_width=1, border_color="#333333")
                card.grid(row=len(self.currencies_scroll.winfo_children()), column=0, sticky="ew", padx=20, pady=10)
                card.grid_columnconfigure(1, weight=1)
                
                lbl_title = ctk.CTkLabel(card, text=f"{symbol} - {coin_name}", font=ctk.CTkFont(size=16, weight="bold"))
                lbl_title.grid(row=0, column=1, sticky="w", pady=(20, 5), padx=(20, 20))

                lbl_price = ctk.CTkLabel(card, text=f"Price: ${price:,.2f} USD{fluctuation}", font=ctk.CTkFont(size=11), text_color=price_color)
                lbl_price.grid(row=1, column=1, sticky="w", pady=5, padx=(20, 20))
                
                lbl_mcap = ctk.CTkLabel(card, text=f"Market Cap: ${mcap:,.0f}", font=ctk.CTkFont(size=9), text_color="gray")
                lbl_mcap.grid(row=2, column=1, sticky="w", pady=(5, 20), padx=(20, 20))
                
                # lbl_id = ctk.CTkLabel(card, text=f"Coin ID: {coin_id}", font=ctk.CTkFont(size=12), text_color="#555555")
                # lbl_id.grid(row=0, column=2, sticky="e", pady=20, padx=20)
        else:
            error_msg = result if not success else "No Currency Data Available"
            lbl = ctk.CTkLabel(self.currencies_scroll, text=f"Data Error: {error_msg}", text_color="red")
            lbl.pack(pady=50)

    def setup_transfer_tab(self):
        frame = ctk.CTkFrame(self.main_frame, fg_color="transparent")
        frame.grid_columnconfigure(0, weight=1)
        self.tabs["transfer"] = frame

        title = ctk.CTkLabel(frame, text="Execute Transaction", font=ctk.CTkFont(size=24, weight="bold"))
        title.grid(row=0, column=0, pady=(0, 20), sticky="w")

        form_frame = ctk.CTkFrame(frame)
        form_frame.grid(row=1, column=0, sticky="n", pady=20)

        ctk.CTkLabel(form_frame, text="Sender User ID:").grid(row=0, column=0, padx=10, pady=10, sticky="e")
        self.entry_sender = ctk.CTkEntry(form_frame, placeholder_text="e.g. 1")
        self.entry_sender.grid(row=0, column=1, padx=10, pady=10)
        self.entry_sender.bind("<KeyRelease>", self.check_live_transfer_status)

        self.lbl_sender_status = ctk.CTkLabel(form_frame, text="Sender Wallet: --", text_color="gray", font=ctk.CTkFont(weight="bold"))
        self.lbl_sender_status.grid(row=0, column=2, padx=10, pady=10, sticky="w")

        ctk.CTkLabel(form_frame, text="Receiver User ID:").grid(row=1, column=0, padx=10, pady=10, sticky="e")
        self.entry_receiver = ctk.CTkEntry(form_frame, placeholder_text="e.g. 2")
        self.entry_receiver.grid(row=1, column=1, padx=10, pady=10)
        self.entry_receiver.bind("<KeyRelease>", self.check_live_transfer_status)
        
        self.lbl_receiver_status = ctk.CTkLabel(form_frame, text="Receiver Wallet: --", text_color="gray", font=ctk.CTkFont(weight="bold"))
        self.lbl_receiver_status.grid(row=1, column=2, padx=10, pady=10, sticky="w")
        
        ctk.CTkLabel(form_frame, text="Crypto:").grid(row=2, column=0, padx=10, pady=10, sticky="e")
        self.crypto_options = {"1 - BTC": 1, "2 - ETH": 2, "3 - USDT": 3, "4 - BNB": 4, "5 - SOL": 5, "6 - XRP": 6}
        self.entry_crypto = ctk.CTkComboBox(form_frame, values=list(self.crypto_options.keys()), command=self.check_live_transfer_status)
        self.entry_crypto.grid(row=2, column=1, padx=10, pady=10)

        ctk.CTkLabel(form_frame, text="Amount:").grid(row=3, column=0, padx=10, pady=10, sticky="e")
        self.entry_amount = ctk.CTkEntry(form_frame, placeholder_text="0.00")
        self.entry_amount.grid(row=3, column=1, padx=10, pady=10)
        
        ctk.CTkLabel(form_frame, text="Type:").grid(row=4, column=0, padx=10, pady=10, sticky="e")
        self.entry_type = ctk.CTkEntry(form_frame)
        self.entry_type.grid(row=4, column=1, padx=10, pady=10)
        self.entry_type.insert(0, "TRANSFER")

        btn_submit = ctk.CTkButton(form_frame, text="Submit Transaction to Oracle DB", fg_color="#10b981", hover_color="#059669", font=ctk.CTkFont(weight="bold"), command=self.submit_transfer)
        btn_submit.grid(row=5, column=0, columnspan=3, pady=30)

    def check_live_transfer_status(self, event=None):
        sender = self.entry_sender.get()
        receiver = self.entry_receiver.get()
        crypto_selection = self.entry_crypto.get()
        
        if crypto_selection in self.crypto_options:
            crypto_id = self.crypto_options[crypto_selection]
            symbol = crypto_selection.split('-')[1].strip()

            # Check Sender
            if sender and sender.isdigit():
                s_success, s_res = self.db.execute_query(f"SELECT wallet_id, balance FROM wallets WHERE user_id = {sender} AND coin_id = {crypto_id}")
                if s_success and s_res[1]:
                    w_id, bal = s_res[1][0]
                    self.lbl_sender_status.configure(text=f"Wallet #{w_id} Found | Avail: {bal:,.4f} {symbol}", text_color="#10b981")
                else:
                    self.lbl_sender_status.configure(text=f"No {symbol} Wallet for User {sender}", text_color="#ef4444")
            else:
                self.lbl_sender_status.configure(text="Sender Wallet: --", text_color="gray")

            # Check Receiver
            if receiver and receiver.isdigit():
                r_success, r_res = self.db.execute_query(f"SELECT wallet_id FROM wallets WHERE user_id = {receiver} AND coin_id = {crypto_id}")
                if r_success and r_res[1]:
                    w_id = r_res[1][0][0]
                    self.lbl_receiver_status.configure(text=f"Wallet #{w_id} Found!", text_color="#10b981")
                else:
                    self.lbl_receiver_status.configure(text=f"No {symbol} Wallet for User {receiver}", text_color="#ef4444")
            else:
                self.lbl_receiver_status.configure(text="Receiver Wallet: --", text_color="gray")

    def submit_transfer(self):
        sender_user = self.entry_sender.get()
        receiver_user = self.entry_receiver.get()
        crypto_selection = self.entry_crypto.get()
        amount = self.entry_amount.get()
        txn_type = self.entry_type.get()

        if not all([sender_user, receiver_user, crypto_selection, amount, txn_type]):
            messagebox.showerror("Validation Error", "All fields are required!")
            return

        try:
            crypto_id = self.crypto_options[crypto_selection]
            symbol = crypto_selection.split('-')[1].strip()

            # Fetch Sender Wallet
            s_succ, s_res = self.db.execute_query(f"SELECT wallet_id FROM wallets WHERE user_id = {sender_user} AND coin_id = {crypto_id}")
            if not s_succ or not s_res[1]:
                messagebox.showerror("Wallet Error", f"Sender User ID {sender_user} does not have a {symbol} wallet!")
                return
            sender_wallet_id = s_res[1][0][0]

            # Fetch Receiver Wallet
            r_succ, r_res = self.db.execute_query(f"SELECT wallet_id FROM wallets WHERE user_id = {receiver_user} AND coin_id = {crypto_id}")
            if not r_succ or not r_res[1]:
                messagebox.showerror("Wallet Error", f"Receiver User ID {receiver_user} does not have a {symbol} wallet!")
                return
            receiver_wallet_id = r_res[1][0][0]

            params = [int(sender_wallet_id), int(receiver_wallet_id), int(crypto_id), float(amount), txn_type]
            success, msg = self.db.call_procedure("pkg_transaction_mgr.process_transaction", params)
            
            if success:
                messagebox.showinfo("Oracle DB Success", "Transaction processed and recorded securely via PL/SQL package!")
                self.entry_amount.delete(0, 'end')
                # Trigger live update to refresh balances immediately
                self.check_live_transfer_status()
            else:
                messagebox.showerror("Oracle DB Error", f"Transaction failed:\n{msg}")
        except Exception as e:
            messagebox.showerror("Data Error", f"Invalid data format or DB Error:\n{str(e)}")

    def setup_create_wallet_tab(self):
        frame = ctk.CTkFrame(self.main_frame, fg_color="transparent")
        frame.grid_columnconfigure(0, weight=1)
        self.tabs["create_wallet"] = frame

        title = ctk.CTkLabel(frame, text="Create New Wallet", font=ctk.CTkFont(size=24, weight="bold"))
        title.grid(row=0, column=0, pady=(0, 20), sticky="w")

        form_frame = ctk.CTkFrame(frame)
        form_frame.grid(row=1, column=0, sticky="n", pady=20)

        ctk.CTkLabel(form_frame, text="Assign to User ID:").grid(row=0, column=0, padx=10, pady=10, sticky="e")
        self.entry_new_user = ctk.CTkEntry(form_frame, placeholder_text="e.g. 1")
        self.entry_new_user.grid(row=0, column=1, padx=10, pady=10)
        self.entry_new_user.bind("<KeyRelease>", self.check_live_user)
        
        self.lbl_user_status = ctk.CTkLabel(form_frame, text="User: --", text_color="gray", font=ctk.CTkFont(weight="bold"))
        self.lbl_user_status.grid(row=0, column=2, padx=10, pady=10, sticky="w")

        ctk.CTkLabel(form_frame, text="Select Currency:").grid(row=1, column=0, padx=10, pady=10, sticky="e")
        self.crypto_options_new = {"1 - BTC": 1, "2 - ETH": 2, "3 - USDT": 3, "4 - BNB": 4, "5 - SOL": 5, "6 - XRP": 6}
        self.entry_new_crypto = ctk.CTkComboBox(form_frame, values=list(self.crypto_options_new.keys()))
        self.entry_new_crypto.grid(row=1, column=1, padx=10, pady=10)

        btn_create = ctk.CTkButton(form_frame, text="Generate Wallet in Oracle", fg_color="#3b82f6", hover_color="#2563eb", font=ctk.CTkFont(weight="bold"), command=self.submit_create_wallet)
        btn_create.grid(row=2, column=0, columnspan=3, pady=30)

    def check_live_user(self, event=None):
        user_id = self.entry_new_user.get()
        if user_id and user_id.isdigit():
            success, result = self.db.execute_query(f"SELECT full_name FROM users WHERE user_id = {user_id}")
            if success and result[1]:
                name = result[1][0][0]
                self.lbl_user_status.configure(text=f"User Found: {name}", text_color="#10b981")
            else:
                self.lbl_user_status.configure(text="No User Found", text_color="#ef4444")
        else:
            self.lbl_user_status.configure(text="User: --", text_color="gray")

    def submit_create_wallet(self):
        user_id = self.entry_new_user.get()
        crypto_selection = self.entry_new_crypto.get()

        if not user_id or not crypto_selection:
            messagebox.showerror("Validation Error", "User ID and Currency are required!")
            return

        try:
            crypto_id = self.crypto_options_new[crypto_selection]
            success, msg = self.db.call_procedure("pkg_wallet_ops.create_wallet", [int(user_id), int(crypto_id)])
            if success:
                messagebox.showinfo("Oracle DB Success", f"New {crypto_selection.split('-')[1].strip()} Wallet successfully created for User {user_id} and stored in the database!")
                self.entry_new_user.delete(0, 'end')
            else:
                messagebox.showerror("Oracle DB Error", f"Wallet creation failed:\n{msg}")
        except Exception as e:
            messagebox.showerror("Data Error", f"Invalid data format or DB error: {str(e)}")

    def setup_manage_users_tab(self):
        frame = ctk.CTkFrame(self.main_frame, fg_color="transparent")
        frame.grid_columnconfigure(0, weight=1)
        self.tabs["manage_users"] = frame

        title = ctk.CTkLabel(frame, text="User Registration & Lookup", font=ctk.CTkFont(size=24, weight="bold"))
        title.grid(row=0, column=0, pady=(0, 20), sticky="w")
        
        # Registration Section
        reg_frame = ctk.CTkFrame(frame)
        reg_frame.grid(row=1, column=0, sticky="ew", pady=(0, 20))
        reg_frame.grid_columnconfigure(1, weight=1)

        ctk.CTkLabel(reg_frame, text="Register New User", font=ctk.CTkFont(size=18, weight="bold")).grid(row=0, column=0, columnspan=2, pady=10, sticky="w", padx=10)

        ctk.CTkLabel(reg_frame, text="Full Name:").grid(row=1, column=0, padx=10, pady=10, sticky="e")
        self.entry_reg_name = ctk.CTkEntry(reg_frame, placeholder_text="e.g. John Doe")
        self.entry_reg_name.grid(row=1, column=1, padx=10, pady=10, sticky="ew")

        ctk.CTkLabel(reg_frame, text="Email Address:").grid(row=2, column=0, padx=10, pady=10, sticky="e")
        self.entry_reg_email = ctk.CTkEntry(reg_frame, placeholder_text="e.g. john@example.com")
        self.entry_reg_email.grid(row=2, column=1, padx=10, pady=10, sticky="ew")

        btn_register = ctk.CTkButton(reg_frame, text="Register User", fg_color="#10b981", hover_color="#059669", font=ctk.CTkFont(weight="bold"), command=self.register_user)
        btn_register.grid(row=3, column=0, columnspan=2, pady=20)

        # Lookup Section
        lookup_frame = ctk.CTkFrame(frame)
        lookup_frame.grid(row=2, column=0, sticky="ew")
        lookup_frame.grid_columnconfigure(1, weight=1)

        ctk.CTkLabel(lookup_frame, text="User KYC Lookup", font=ctk.CTkFont(size=18, weight="bold")).grid(row=0, column=0, columnspan=2, pady=10, sticky="w", padx=10)

        ctk.CTkLabel(lookup_frame, text="User ID:").grid(row=1, column=0, padx=10, pady=10, sticky="e")
        self.entry_lookup_id = ctk.CTkEntry(lookup_frame, placeholder_text="e.g. 1")
        self.entry_lookup_id.grid(row=1, column=1, padx=10, pady=10, sticky="ew")
        self.entry_lookup_id.bind("<KeyRelease>", self.lookup_user)

        self.lbl_lookup_result = ctk.CTkLabel(lookup_frame, text="Details: --", text_color="gray", font=ctk.CTkFont(size=14))
        self.lbl_lookup_result.grid(row=2, column=0, columnspan=2, padx=10, pady=20)

        self.btn_verify_kyc = ctk.CTkButton(lookup_frame, text="Approve KYC Verification", fg_color="#3b82f6", hover_color="#2563eb", font=ctk.CTkFont(weight="bold"), command=self.verify_user_kyc, state="disabled")
        self.btn_verify_kyc.grid(row=3, column=0, columnspan=2, pady=(0, 20))

    def register_user(self):
        name = self.entry_reg_name.get()
        email = self.entry_reg_email.get()

        if not name or not email:
            messagebox.showerror("Validation Error", "Full Name and Email are required!")
            return

        try:
            query = f"INSERT INTO users (user_id, full_name, email, is_verified, created_at) VALUES (SEQ_USER_ID.NEXTVAL, '{name}', '{email}', 'NO', SYSDATE)"
            success, msg = self.db.execute_query(query)
            if success:
                self.db.execute_query("COMMIT")
                messagebox.showinfo("Success", f"User {name} registered successfully!")
                self.entry_reg_name.delete(0, 'end')
                self.entry_reg_email.delete(0, 'end')
            else:
                messagebox.showerror("DB Error", f"Registration failed:\n{msg}")
        except Exception as e:
            messagebox.showerror("Error", f"An error occurred: {str(e)}")

    def lookup_user(self, event=None):
        user_id = self.entry_lookup_id.get()
        if user_id and user_id.isdigit():
            success, result = self.db.execute_query(f"SELECT full_name, email, is_verified FROM users WHERE user_id = {user_id}")
            if success and result[1]:
                name, email, is_verified = result[1][0]
                if is_verified == 'YES':
                    color = "#10b981"
                    self.btn_verify_kyc.configure(state="disabled")
                else:
                    color = "#ef4444"
                    self.btn_verify_kyc.configure(state="normal")
                
                status_text = f"Name: {name} | Email: {email} | KYC Verified: "
                self.lbl_lookup_result.configure(text=f"{status_text}{is_verified}", text_color=color)
            else:
                self.lbl_lookup_result.configure(text="No user found.", text_color="gray")
                self.btn_verify_kyc.configure(state="disabled")
        else:
            self.lbl_lookup_result.configure(text="Details: --", text_color="gray")
            self.btn_verify_kyc.configure(state="disabled")

    def verify_user_kyc(self):
        user_id = self.entry_lookup_id.get()
        if not user_id or not user_id.isdigit():
            return
            
        success, msg = self.db.execute_query(f"UPDATE users SET is_verified = 'YES' WHERE user_id = {user_id}")
        if success:
            self.db.execute_query("COMMIT")
            messagebox.showinfo("Success", f"User {user_id} KYC has been officially approved!")
            self.lookup_user() # Refresh the lookup display
        else:
            messagebox.showerror("Error", f"Failed to approve KYC:\n{msg}")

if __name__ == "__main__":
    app = CryptoApp()
    app.mainloop()
