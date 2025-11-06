import { useState, useEffect } from 'react'
import axios from 'axios'
import './App.css'

function App() {
  const [tasks, setTasks] = useState([])
  const [newTask, setNewTask] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
// Detecta se tá no container ou no browser
  const getAPIUrl = () => {
    // Se tá rodando no browser (window existe), usa localhost
    if (typeof window !== 'undefined') {
      return 'http://localhost:8081/api'
    }
    // Se tá no servidor, usa o nome do container
    return 'http://appvamosla-backend:8080/api'
  }

  const API_URL = import.meta.env.VITE_API_URL || getAPIUrl()

  useEffect(() => {
    fetchTasks()
  }, [])

  const fetchTasks = async () => {
    try {
      setLoading(true)
      const response = await axios.get(`${API_URL}/tasks`)
      setTasks(response.data)
      setError(null)
    } catch (err) {
      console.error('Erro ao buscar tarefas:', err)
      setError('Erro ao conectar com backend')
    } finally {
      setLoading(false)
    }
  }

  const addTask = async (e) => {
    e.preventDefault()
    if (!newTask.trim()) return

    try {
      const response = await axios.post(`${API_URL}/tasks`, {
        title: newTask,
        completed: false
      })
      setTasks([...tasks, response.data])
      setNewTask('')
      setError(null)
    } catch (err) {
      console.error('Erro ao criar tarefa:', err)
      setError('Erro ao criar tarefa')
    }
  }

  const toggleTask = async (id) => {
    try {
      const task = tasks.find(t => t.id === id)
      const response = await axios.put(`${API_URL}/tasks/${id}`, {
        ...task,
        completed: !task.completed
      })
      setTasks(tasks.map(t => t.id === id ? response.data : t))
      setError(null)
    } catch (err) {
      console.error('Erro ao atualizar tarefa:', err)
      setError('Erro ao atualizar tarefa')
    }
  }

  const deleteTask = async (id) => {
    try {
      await axios.delete(`${API_URL}/tasks/${id}`)
      setTasks(tasks.filter(t => t.id !== id))
      setError(null)
    } catch (err) {
      console.error('Erro ao deletar tarefa:', err)
      setError('Erro ao deletar tarefa')
    }
  }

  return (
    <div className="container">
      <header className="header">
        <h1>✨ VAMOSLA - Task Manager</h1>
        <p>Gerenciador de tarefas simples e eficiente</p>
      </header>

      {error && <div className="error">{error}</div>}

      <form onSubmit={addTask} className="form">
        <input
          type="text"
          value={newTask}
          onChange={(e) => setNewTask(e.target.value)}
          placeholder="Adicione uma nova tarefa..."
          className="input"
        />
        <button type="submit" className="btn btn-add">Adicionar</button>
      </form>

      {loading && <p className="loading">Carregando...</p>}

      <div className="tasks">
        {tasks.length === 0 ? (
          <p className="empty">Nenhuma tarefa. Crie uma!</p>
        ) : (
          tasks.map(task => (
            <div key={task.id} className="task">
              <input
                type="checkbox"
                checked={task.completed}
                onChange={() => toggleTask(task.id)}
                className="checkbox"
              />
              <span className={task.completed ? 'completed' : ''}>
                {task.title}
              </span>
              <button
                onClick={() => deleteTask(task.id)}
                className="btn btn-delete"
              >
                Deletar
              </button>
            </div>
          ))
        )}
      </div>
    </div>
  )
}

export default App