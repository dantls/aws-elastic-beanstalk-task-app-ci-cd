const Task = ({ task, onDelete, onToggle }) => {
  return (
    <div
      className={`task ${task.importante ? "reminder" : ""}`}
      onDoubleClick={() => onToggle(task.uuid)}
    >
      <h3>
        {task.titulo}{" "}
        <span
          style={{ color: "var(--danger-color)", cursor: "pointer" }}
          onClick={() => onDelete(task.uuid)}
        >
          ✕
        </span>
      </h3>
      <p>{task.dia_atividade}</p>
    </div>
  );
};

export default Task;
