package com.appvamosla.service;

import com.appvamosla.model.Task;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ExecutionException;

@Service
public class TaskService {
    private static final String COLLECTION_NAME = "tasks";

    @Autowired
    private Firestore firestore;

    public List<Task> getAllTasks() {
        List<Task> tasks = new ArrayList<>();
        try {
            QuerySnapshot querySnapshot = firestore
                    .collection(COLLECTION_NAME)
                    .get()
                    .get();

            querySnapshot.getDocuments().forEach(doc ->
                    tasks.add(doc.toObject(Task.class))
            );
        } catch (InterruptedException | ExecutionException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Erro ao buscar tarefas", e);
        }
        return tasks;
    }

    public Task getTaskById(String id) {
        try {
            return firestore
                    .collection(COLLECTION_NAME)
                    .document(id)
                    .get()
                    .get()
                    .toObject(Task.class);
        } catch (InterruptedException | ExecutionException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Erro ao buscar tarefa", e);
        }
    }

    public Task createTask(Task task) {
        try {
            String id = UUID.randomUUID().toString();
            long now = System.currentTimeMillis();

            task.setId(id);
            task.setCreatedAt(now);
            task.setUpdatedAt(now);

            firestore
                    .collection(COLLECTION_NAME)
                    .document(id)
                    .set(task)
                    .get();

            return task;
        } catch (InterruptedException | ExecutionException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Erro ao criar tarefa", e);
        }
    }

    public Task updateTask(String id, Task task) {
        try {
            task.setId(id);
            task.setUpdatedAt(System.currentTimeMillis());

            firestore
                    .collection(COLLECTION_NAME)
                    .document(id)
                    .set(task)
                    .get();

            return task;
        } catch (InterruptedException | ExecutionException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Erro ao atualizar tarefa", e);
        }
    }

    public void deleteTask(String id) {
        try {
            firestore
                    .collection(COLLECTION_NAME)
                    .document(id)
                    .delete()
                    .get();
        } catch (InterruptedException | ExecutionException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Erro ao deletar tarefa", e);
        }
    }
}