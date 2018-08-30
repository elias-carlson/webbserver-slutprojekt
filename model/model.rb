module WEBBSERVER_SLUTPROJEKT
    DB_PATH = 'db/database.db'

    def db_connect
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true
        return db
    end

    def get_user username
        db = db_connect()
        result = db.execute("SELECT * FROM users WHERE username=?", [username])
        return result.first
    end

    def create_user username, password
        db = db_connect()
        password_digest = BCrypt::Password.create(password)
        db.execute("INSERT INTO users(username, password) VALUES (?,?)", [username, password_digest])
    end

    def get_articles
        db = db_connect()
        result = db.execute("SELECT * FROM articles")
        return result
    end

    def add_to_cart article_id, user_id
        db = db_connect()
        db.results_as_hash = false

        existing = db.execute("SELECT * FROM orders WHERE article_id = ? AND user_id = ?", [article_id, user_id])

        if existing != []
            amount = db.execute("SELECT amount FROM orders WHERE id=?", existing[0][0])[0][0]
            if amount == nil
                amount = 1
            else
                amount += 1
            end
            db.execute("UPDATE orders SET amount =? WHERE id =?", [amount, existing[0][0]])
        else
            db.execute("INSERT INTO orders(article_id, user_id) VALUES (?,?)", [article_id, user_id])
            result = db.execute("SELECT MAX(id) FROM orders")
            result = result[0][0]
            amount = db.execute("SELECT amount FROM orders WHERE id=?", result)[0][0]
            if amount == nil
                amount = 1
            else
                amount += 1
            end
            db.execute("UPDATE orders SET amount =? WHERE id =?", [amount, result])
        end
    end

    def remove_from_cart(article_id, user_id)
        db = db_connect()
        
        result = db.execute("SELECT amount FROM orders WHERE article_id = ? AND user_id = ?", [article_id, user_id]) 

        if result[0]["amount"] != 0  
            result[0]["amount"] -=1
            db.execute("UPDATE orders SET amount=? WHERE user_id=? AND article_id=?", [result[0]["amount"], user_id, article_id])
        end
    end

    def get_cart(user_id)
        db = db_connect()
        articles = []
        total_amount = 0

        result = db.execute("SELECT * FROM orders WHERE user_id=?", [user_id])

        result.each do |i|
            if i["amount"] == 0
                db.execute("DELETE FROM orders WHERE user_id=? AND article_id=?", [user_id, i["article_id"]])
            end
            total_amount += i["amount"]
            article_info = db.execute("SELECT name, price, description FROM articles WHERE id=?", [i["article_id"]])
            article_info = article_info[0]
            articles << article_info
        end

        result = db.execute("SELECT * FROM orders WHERE user_id=?", [user_id])

        return result, articles, total_amount
    end
end