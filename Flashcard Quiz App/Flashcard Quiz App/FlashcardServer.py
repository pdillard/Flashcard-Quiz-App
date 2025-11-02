#python3

import socket
import threading
import json
import random
import time


HOST = '0.0.0.0'
PORT = 5555

# Game settings
MIN_PLAYERS = 2
TOTAL_QUESTIONS = 5
ANSWER_TIME_LIMIT = 30

FLASHCARD_POOL = [
    {
        'question': 'What is 5 + 7?',
        'answer': '12',
        'category': 'Math'
    },
    {
        'question': 'What is the smallest prime number?',
        'answer': '2',
        'category': 'Math'
    },
    {
        'question': 'What is 10 x 9?',
        'answer': '90',
        'category': 'Math'
    },
    {
        'question': 'What is 15 - 8?',
        'answer': '7',
        'category': 'Math'
    },
    {
        'question': 'What is 12 ÷ 3?',
        'answer': '4',
        'category': 'Math'
    },
    {
        'question': 'What is the largest planet in our solar system?',
        'answer': 'Jupiter',
        'category': 'Science'
    },
    {
        'question': 'What is the chemical symbol for water?',
        'answer': 'H2O',
        'category': 'Science'
    },
    {
        'question': 'How many bones are in the human body?',
        'answer': '206',
        'category': 'Science'
    },
    {
        'question': 'What gas do plants absorb from the atmosphere?',
        'answer': 'Carbon Dioxide',
        'category': 'Science'
    },
    {
        'question': 'What year did World War II end?',
        'answer': '1945',
        'category': 'History'
    },
    {
        'question': 'Who was the first President of the United States?',
        'answer': 'Washington',
        'category': 'History'
    },
    {
        'question': 'In what year did Christopher Columbus reach the Americas?',
        'answer': '1492',
        'category': 'History'
    },
    {
        'question': 'What is the capital of France?',
        'answer': 'Paris',
        'category': 'Geography'
    },
    {
        'question': 'What is the capital of Japan?',
        'answer': 'Tokyo',
        'category': 'Geography'
    },
    {
        'question': 'How many continents are there?',
        'answer': '7',
        'category': 'Geography'
    },
    {
        'question': 'What is the largest ocean on Earth?',
        'answer': 'Pacific',
        'category': 'Geography'
    },
    {
        'question': 'Who wrote Romeo and Juliet?',
        'answer': 'Shakespeare',
        'category': 'Literature'
    },
    {
        'question': 'Who wrote "To Kill a Mockingbird"?',
        'answer': 'Harper Lee',
        'category': 'Literature'
    },
    {
        'question': 'What is the first book of the Bible?',
        'answer': 'Genesis',
        'category': 'Literature'
    }
]

# List of connected players: [{'name': str, 'socket': socket, 'score': int, 'ready': bool}]
players = []
players_lock = threading.Lock()

# Game state
game_started = False
game_lock = threading.Lock()
current_question_index = 0
questions = []
question_timer = None


def send_message(client_socket, message_dict):
    """
    Send a JSON message to a client
    
    CONCEPT: JSON Serialization
    - Converts Python dict to JSON string
    - Encodes as UTF-8 bytes for network transmission
    - Adds newline delimiter so client knows message is complete
    
    Args:
        client_socket: The socket to send to
        message_dict: Dictionary to send as JSON
    """
    try:
        json_string = json.dumps(message_dict)
        message_bytes = (json_string + '\n').encode('utf-8')
        client_socket.sendall(message_bytes)
        print(f"→ Sent: {message_dict.get('type', 'UNKNOWN')} to client")
    except Exception as e:
        print(f"Error sending message: {e}")


def broadcast(message_dict, exclude_socket=None):
    """
    Send a message to all connected players
    
    CONCEPT: Broadcasting
    - Iterate through all connected clients
    - Send same message to each one
    - Optionally exclude one client (e.g., the sender)
    
    Args:
        message_dict: Message to send
        exclude_socket: Optional socket to skip
    """
    with players_lock:
        for player in players[:]:
            if player['socket'] != exclude_socket:
                try:
                    send_message(player['socket'], message_dict)
                except Exception as e:
                    print(f"Error broadcasting to {player['name']}: {e}")


def get_player_by_socket(client_socket):
    """Find player data by their socket"""
    with players_lock:
        for player in players:
            if player['socket'] == client_socket:
                return player
    return None


def remove_player(client_socket):
    """Remove a player from the game"""
    with players_lock:
        global players
        player = get_player_by_socket(client_socket)
        if player:
            players = [p for p in players if p['socket'] != client_socket]
            print(f"✗ {player['name']} left the game")
            
            # Notify others
            broadcast({
                'type': 'PLAYER_LEFT',
                'player_name': player['name'],
                'players_count': len(players)
            })


def broadcast_scores():
    """
    Send current leaderboard to all players
    """
    with players_lock:
        scores = [
            {'name': p['name'], 'score': p['score']}
            for p in players
        ]
        
        # Sort by score (highest first)
        scores.sort(key=lambda x: x['score'], reverse=True)
        
        message = {
            'type': 'SCORE_UPDATE',
            'scores': scores
        }
        
        # Broadcast while still holding lock to prevent race conditions
        for player in players[:]:
            try:
                send_message(player['socket'], message)
            except Exception as e:
                print(f"Error sending scores to {player['name']}: {e}")


# ============================================================================
# GAME LOGIC
# ============================================================================

def initialize_game():
    """
    Prepare a new game
    
    CONCEPT: Game Initialization
    - Select random questions from pool
    - Reset all player scores
    - Set game state flags
    """
    global questions, current_question_index, game_started, question_timer
    
    with game_lock:
        # Cancel any existing timer
        if question_timer:
            question_timer.cancel()
            question_timer = None
        
        # Select random questions
        questions = random.sample(FLASHCARD_POOL, min(TOTAL_QUESTIONS, len(FLASHCARD_POOL)))
        current_question_index = 0
        game_started = True
    
    # Reset all player scores
    with players_lock:
        for player in players:
            player['score'] = 0
            player['ready'] = False
            player['answered'] = False
    
    print(f"✓ Game initialized with {len(questions)} questions")


def send_next_question():
    """
    Send the next question to all players
    
    CONCEPT: Game Flow Control
    - Check if more questions exist
    - Package question data as JSON
    - Broadcast to all players
    - If no more questions, end game
    """
    global current_question_index, question_timer
    
    with game_lock:
        if not game_started:
            return
        
        if current_question_index < len(questions):
            question_data = questions[current_question_index]
            
            # Reset answered status for all players
            with players_lock:
                for player in players:
                    player['answered'] = False
            
            message = {
                'type': 'QUESTION',
                'question': question_data['question'],
                'category': question_data['category'],
                'number': current_question_index + 1,
                'total': len(questions),
                'time_limit': ANSWER_TIME_LIMIT
            }
            
            broadcast(message)
            print(f"📝 Sent question {current_question_index + 1}/{len(questions)}")
            
            current_question_index += 1
            
            question_timer = threading.Timer(ANSWER_TIME_LIMIT, auto_next_question)
            question_timer.daemon = True
            question_timer.start()
        else:
            end_game()


def auto_next_question():
    """
    Automatically move to next question after time limit
    """
    print("⏰ Time's up! Moving to next question...")
    
    # Notify players that time is up
    broadcast({
        'type': 'TIME_UP',
        'message': 'Time is up! Moving to next question...'
    })
    
    time.sleep(2)
    send_next_question()


def handle_answer(client_socket, submitted_answer):
    """
    Process a player's answer
    
    CONCEPT: Answer Validation
    - Find which player submitted answer
    - Compare to correct answer (case-insensitive)
    - Update player's score
    - Send result back to player
    - Broadcast updated scores to all
    
    Args:
        client_socket: Socket of player who answered
        submitted_answer: Their answer string
    """
    player = get_player_by_socket(client_socket)
    if not player:
        return
    
    if player.get('answered', False):
        send_message(client_socket, {
            'type': 'ERROR',
            'message': 'You have already answered this question'
        })
        return
    
    with game_lock:
        question_idx = current_question_index - 1
    
    # Get correct answer for current question
    if question_idx >= 0 and question_idx < len(questions):
        correct_answer = questions[question_idx]['answer']
        
        # Compare answers (case-insensitive, strip whitespace)
        is_correct = submitted_answer.strip().lower() == correct_answer.strip().lower()
        
        # Update score and mark as answered
        with players_lock:
            player['answered'] = True
            if is_correct:
                player['score'] += 10
                print(f"✓ {player['name']} answered correctly! Score: {player['score']}")
            else:
                print(f"✗ {player['name']} answered incorrectly")
        
        # Send individual result to this player
        response = {
            'type': 'ANSWER_RESULT',
            'correct': is_correct,
            'correct_answer': correct_answer,
            'your_score': player['score']
        }
        send_message(client_socket, response)
        
        # Broadcast updated scores to everyone
        broadcast_scores()
        
        with players_lock:
            all_answered = all(p.get('answered', False) for p in players)
        
        if all_answered:
            global question_timer
            if question_timer:
                question_timer.cancel()
                question_timer = None
            
            print("✓ All players answered! Moving to next question...")
            time.sleep(2)
            send_next_question()


def end_game():
    """
    End the current game and announce winner
    
    CONCEPT: Game Conclusion
    - Calculate final rankings
    - Determine winner
    - Send final results to all players
    - Reset game state
    """
    global game_started, question_timer
    
    with game_lock:
        game_started = False
        
        # Cancel any active timer
        if question_timer:
            question_timer.cancel()
            question_timer = None
    
    with players_lock:
        # Sort players by score
        sorted_players = sorted(players, key=lambda p: p['score'], reverse=True)
        
        final_scores = [
            {'name': p['name'], 'score': p['score'], 'rank': i + 1}
            for i, p in enumerate(sorted_players)
        ]
    
    winner = final_scores[0] if final_scores else None
    
    message = {
        'type': 'GAME_END',
        'winner': winner['name'] if winner else 'No one',
        'final_scores': final_scores
    }
    
    broadcast(message)
    print(f"🏆 Game ended! Winner: {winner['name'] if winner else 'No one'}")


def check_start_game():
    """
    Check if we can start the game
    
    CONCEPT: Game Start Conditions
    - Require minimum number of players
    - All players must be ready
    - Game not already started
    """
    with game_lock:
        if game_started:
            return False
    
    with players_lock:
        if len(players) < MIN_PLAYERS:
            return False
        
        # Check if all players are ready
        all_ready = all(p.get('ready', False) for p in players)
        
        if all_ready:
            return True
    
    return False


# ============================================================================
# CLIENT HANDLER
# ============================================================================

def handle_client(client_socket, address):
    """
    Handle all communication with a single client
    
    CONCEPT: Client Thread
    - Each client gets its own thread
    - Continuously listens for messages
    - Parses JSON and routes to appropriate handler
    - Cleans up on disconnect
    
    This is the heart of the server - it runs in a loop for each
    connected client, waiting for messages and responding appropriately.
    
    Args:
        client_socket: The socket for this client
        address: Client's IP address and port
    """
    print(f"✓ New connection from {address}")
    
    player_name = None
    buffer = ""  # Buffer for incomplete messages
    
    try:
        while True:
            # Receive data from client
            # CONCEPT: recv() blocks until data arrives
            data = client_socket.recv(4096)
            
            if not data:
                # Empty data means client disconnected
                print(f"Client {address} disconnected")
                break
            
            # Decode bytes to string and add to buffer
            buffer += data.decode('utf-8')
            
            # Process complete messages (delimited by newlines)
            while '\n' in buffer:
                line, buffer = buffer.split('\n', 1)
                
                if not line.strip():
                    continue
                
                try:
                    # Parse JSON message
                    message = json.loads(line)
                    message_type = message.get('type')
                    
                    print(f"← Received from {address}: {message_type}")
                    
                    # ========================================
                    # MESSAGE ROUTING
                    # ========================================
                    
                    if message_type == 'JOIN':
                        """
                        Client wants to join the game
                        
                        Expected message:
                        {"type": "JOIN", "player_name": "Alice"}
                        """
                        player_name = message.get('player_name', 'Anonymous')
                        
                        # Add player to game
                        with players_lock:
                            players.append({
                                'name': player_name,
                                'socket': client_socket,
                                'score': 0,
                                'ready': False,
                                'answered': False
                            })
                        
                        print(f"✓ {player_name} joined! Total players: {len(players)}")
                        
                        # Send confirmation to this player
                        response = {
                            'type': 'JOINED',
                            'status': 'success',
                            'message': f'Welcome {player_name}!',
                            'players_count': len(players),
                            'min_players': MIN_PLAYERS
                        }
                        send_message(client_socket, response)
                        
                        # Notify all other players
                        broadcast({
                            'type': 'PLAYER_JOINED',
                            'player_name': player_name,
                            'players_count': len(players)
                        }, exclude_socket=client_socket)
                    
                    elif message_type == 'READY':
                        """
                        Player is ready to start
                        
                        Expected message:
                        {"type": "READY"}
                        """
                        player = get_player_by_socket(client_socket)
                        if player:
                            with players_lock:
                                player['ready'] = True
                            print(f"✓ {player['name']} is ready")
                            
                            # Notify all players
                            broadcast({
                                'type': 'PLAYER_READY',
                                'player_name': player['name']
                            })
                            
                            # Check if we can start game
                            if check_start_game():
                                print("🎮 Starting game...")
                                initialize_game()
                                
                                # Notify all players game is starting
                                broadcast({
                                    'type': 'GAME_STARTING',
                                    'message': 'Get ready! Game starting...'
                                })
                                
                                # Wait a moment then send first question
                                time.sleep(2)
                                send_next_question()
                    
                    elif message_type == 'ANSWER':
                        """
                        Player submitted an answer
                        
                        Expected message:
                        {"type": "ANSWER", "answer": "12"}
                        """
                        with game_lock:
                            if not game_started:
                                send_message(client_socket, {
                                    'type': 'ERROR',
                                    'message': 'Game has not started yet'
                                })
                                continue
                        
                        answer = message.get('answer', '')
                        handle_answer(client_socket, answer)
                    
                    elif message_type == 'NEXT':
                        """
                        Request next question (usually from host)
                        
                        Expected message:
                        {"type": "NEXT"}
                        """
                        with game_lock:
                            if game_started:
                                send_next_question()
                    
                    elif message_type == 'PING':
                        """
                        Heartbeat to check connection
                        
                        Expected message:
                        {"type": "PING"}
                        """
                        send_message(client_socket, {'type': 'PONG'})
                    
                    else:
                        # Unknown message type
                        print(f"⚠ Unknown message type: {message_type}")
                        send_message(client_socket, {
                            'type': 'ERROR',
                            'message': f'Unknown message type: {message_type}'
                        })
                
                except json.JSONDecodeError as e:
                    print(f"⚠ Invalid JSON from {address}: {e}")
                    send_message(client_socket, {
                        'type': 'ERROR',
                        'message': 'Invalid JSON format'
                    })
    
    except Exception as e:
        print(f"⚠ Error handling client {address}: {e}")
    
    finally:
        # Clean up when client disconnects
        print(f"✗ Cleaning up connection from {address}")
        remove_player(client_socket)
        try:
            client_socket.close()
        except:
            pass


# ============================================================================
# MAIN SERVER
# ============================================================================

def start_server():
    """
    Start the TCP server
    
    CONCEPT: Server Main Loop
    1. Create a TCP socket
    2. Bind to address and port
    3. Listen for connections
    4. Accept clients in infinite loop
    5. Spawn thread for each client
    
    This function runs forever, accepting new clients and
    creating a thread for each one.
    """
    # Create TCP socket
    # CONCEPT: AF_INET = IPv4, SOCK_STREAM = TCP
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # Allow reusing address immediately after server restart
    # CONCEPT: SO_REUSEADDR prevents "Address already in use" error
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        # Bind socket to address and port
        # CONCEPT: This claims the port for our server
        server_socket.bind((HOST, PORT))
        
        # Listen for connections (queue up to 5 pending connections)
        # CONCEPT: Server is now ready to accept clients
        server_socket.listen(5)
        
        print("=" * 60)
        print("🎮 FLASHCARD QUIZ SERVER")
        print("=" * 60)
        print(f"Server listening on {HOST}:{PORT}")
        print(f"Minimum players: {MIN_PLAYERS}")
        print(f"Questions per game: {TOTAL_QUESTIONS}")
        print(f"Answer time limit: {ANSWER_TIME_LIMIT} seconds")
        print(f"Total flashcards available: {len(FLASHCARD_POOL)}")
        print(f"Waiting for connections...")
        print("=" * 60)
        
        # Main accept loop
        # CONCEPT: This runs forever, accepting new clients
        while True:
            # Accept a client connection (BLOCKS until client connects)
            # CONCEPT: Returns new socket for this specific client
            client_socket, address = server_socket.accept()
            
            # Create new thread to handle this client
            # CONCEPT: Each client gets independent thread
            # - target: function to run in thread
            # - args: arguments to pass to function
            # - daemon: thread dies when main program exits
            client_thread = threading.Thread(
                target=handle_client,
                args=(client_socket, address),
                daemon=True
            )
            client_thread.start()
            
            print(f"Active threads: {threading.active_count()}")
    
    except KeyboardInterrupt:
        print("\n\n⚠ Server shutting down...")
    
    except Exception as e:
        print(f"⚠ Server error: {e}")
    
    finally:
        # Clean up
        print("Closing server socket...")
        server_socket.close()
        print("✓ Server stopped")


# ============================================================================
# ENTRY POINT
# ============================================================================

if __name__ == '__main__':
    """
    Entry point when running script directly
    
    CONCEPT: Python idiom for main function
    - Only runs if this file is executed (not imported)
    - Keeps code organized
    """
    start_server()
